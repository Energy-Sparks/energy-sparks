# frozen_string_literal: true

module Usage
  class AnnualUsageCalculationService
    include AnalysableMixin

    DAYSINYEAR = 363

    # Create a service capable of calculating the annual energy usage for a meter
    #
    # To calculate usage for a whole school provide the aggregate electricity
    # meter as the parameter.
    #
    # @param [Dashboard::Meter] analytics_meter the meter to use for calculations
    # @param [Date] asof_date the date to use as the basis for calculations
    #
    # @raise [EnergySparksUnexpectedStateException] if meter isn't an electricity meter
    def initialize(analytics_meter, asof_date = Date.current)
      @meter = analytics_meter
      @asof_date = asof_date
    end

    # Do we have enough data to run the calculations?
    def enough_data?
      meter_data_checker.one_years_data?
    end

    delegate :one_years_data?, to: :meter_data_checker
    delegate :at_least_x_days_data?, to: :meter_data_checker
    delegate :date_when_enough_data_available, to: :meter_data_checker

    # If we don't have enough data, then when will it be available?
    def data_available_from
      meter_data_checker.date_when_enough_data_available(365)
    end

    # Calculate the annual usage over a twelve month period
    #
    # The period is specified using the +period+ parameter
    #
    # Values are not temperature adjusted
    #
    # @param period either :this_year or :last_year
    # @return [CombinedUsageMetric] the calculated usage for the specified period
    def annual_usage(period: :this_year)
      start_date, end_date = dates_for_period(period)
      # using £ not £current as this is historical usage
      CombinedUsageMetric.new(
        kwh: calculate(start_date, end_date, :kwh),
        gbp: calculate(start_date, end_date, :£),
        co2: calculate(start_date, end_date, :co2)
      )
    end

    # Calculates the annual usage for this year and last year and
    # returns a CombinedUsageMetric with the changes.
    #
    # Values are not temperature adjusted
    #
    # The percentage difference is based on the kwh usage. If you need
    # other behaviour, then just calculate the individual annual usage and
    # derive as needed.
    #
    # If there isn't sufficient data (>2 years) then the method will return nil
    #
    # @return [CombinedUsageMetric] the difference between this year and last year
    def usage_change_since_last_period(period)
      last_period = case period
                    when :this_year
                      :last_year
                    when :last_month
                      :previous_month
                    else
                      raise 'invalid period'
                    end
      return nil unless has_full_previous_period_worth_of_data?(last_period)

      this_period = annual_usage(period:)
      last_period = annual_usage(period: last_period)
      kwh = this_period.kwh - last_period.kwh
      CombinedUsageMetric.new(
        kwh: kwh,
        gbp: this_period.gbp - last_period.gbp,
        co2: this_period.co2 - last_period.co2,
        percent: kwh / last_period.kwh
      )
    end

    def annual_usage_change_since_last_year
      usage_change_since_last_period(:this_year)
    end

    # :this_year is last 12 months
    # :last_year is previous 12 months
    def dates_for_period(period)
      start_date = case period
                   when :this_year
                     @asof_date - DAYSINYEAR
                   when :last_month, :previous_month
                     @asof_date.prev_month.beginning_of_month
                   end
      start_date = @meter.amr_data.start_date if start_date&.<(@meter.amr_data.start_date)
      case period
      when :this_year
        [start_date, @asof_date]
      when :last_year
        prev_date = @asof_date - DAYSINYEAR - 1
        [prev_date - DAYSINYEAR, prev_date]
      when :last_month
        [start_date, start_date.end_of_month]
      when :previous_month
        [start_date.prev_month, start_date.prev_month.end_of_month]
      else
        raise 'Invalid year'
      end
    end

    private

    def has_full_previous_period_worth_of_data?(period)
      start_date, _end_date = dates_for_period(period)
      @meter.amr_data.start_date <= start_date
    end

    # Calculate usage values between two dates, returning the
    # results in the specified data type
    #
    # Delegates to the AMR data class for this meter whose kwh_date_range
    # method does the same thing.
    def calculate(start_date, end_date, data_type = :kwh)
      amr_data = @meter.amr_data
      amr_data.kwh_date_range(start_date, end_date, data_type)
    rescue EnergySparksNotEnoughDataException
      nil
    end

    def meter_data_checker
      @meter_data_checker ||= Util::MeterDateRangeChecker.new(@meter, @asof_date)
    end
  end
end
