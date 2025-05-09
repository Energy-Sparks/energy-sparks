# frozen_string_literal: true

require 'active_support/core_ext/module'

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
    def initialize(analytics_meter, asof_date = Date.today)
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
        £: calculate(start_date, end_date, :£),
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
    def annual_usage_change_since_last_year
      return nil unless has_full_previous_years_worth_of_data?

      this_year = annual_usage(period: :this_year)
      last_year = annual_usage(period: :last_year)
      kwh = this_year.kwh - last_year.kwh
      CombinedUsageMetric.new(
        kwh: kwh,
        £: this_year.£ - last_year.£,
        co2: this_year.co2 - last_year.co2,
        percent: kwh / last_year.kwh
      )
    end

    private

    # :this_year is last 12 months
    # :last_year is previous 12 months
    def dates_for_period(period)
      start_date = @asof_date - DAYSINYEAR
      start_date = @meter.amr_data.start_date if start_date < @meter.amr_data.start_date
      case period
      when :this_year
        [start_date, @asof_date]
      when :last_year
        prev_date = @asof_date - DAYSINYEAR - 1
        [prev_date - DAYSINYEAR, prev_date]
      else
        raise 'Invalid year'
      end
    end

    def has_full_previous_years_worth_of_data?
      start_date, _end_date = dates_for_period(:last_year)
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
