# frozen_string_literal: true

module Costs
  class AccountingCostsService
    include AnalysableMixin
    DAYSINYEAR = 365

    def initialize(analytics_meter, end_date = nil)
      @meter = analytics_meter
      @end_date = end_date || @meter.amr_data.end_date
      @start_date = [@end_date - DAYSINYEAR, @meter.amr_data.start_date].max
    end

    # Do we have enough data to run the calculations?
    def enough_data?
      meter_data_checker.one_years_data?
    end

    # If we don't have enough data, then when will it be available?
    def data_available_from
      enough_data? ? nil : meter_data_checker.date_when_enough_data_available(365)
    end

    # return cost, up to one year
    def annual_cost
      cost = @meter.amr_data.kwh_date_range(@start_date, @end_date, :accounting_cost)
      days = @meter.amr_data.end_date - @start_date + 1
      OpenStruct.new(
        £: cost,
        days: days,
        start_date: @start_date,
        end_date: @end_date
      )
    end

    # return annual usage for this year or previous year
    #
    # differs from annual usage calculation service as it uses :accounting_cost not :£
    def annual_usage(period: :this_year)
      period_start_date, period_end_date = dates_for_period(period)
      # using £ not £current as this is historical usage
      CombinedUsageMetric.new(
        kwh: calculate(period_start_date, period_end_date, :kwh),
        £: calculate(period_start_date, period_end_date, :accounting_cost),
        co2: calculate(period_start_date, period_end_date, :co2)
      )
    end

    # Calculates the annual usage for this year and last year and
    # returns a CombinedUsageMetric with the changes.
    #
    # differs from annual usage calculation service as it uses :accounting_cost not :£
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
      case period
      when :this_year
        [@end_date - DAYSINYEAR + 1, @end_date]
      when :last_year
        last_year_end_date = @end_date - DAYSINYEAR
        [last_year_end_date - DAYSINYEAR + 1, last_year_end_date]
      else
        raise 'Invalid year'
      end
    end

    def has_full_previous_years_worth_of_data?
      previous_year_start_date, _previous_year_end_date = dates_for_period(:last_year)
      @start_date <= previous_year_start_date
    end

    # Calculate usage values between two dates, returning the
    # results in the specified data type
    #
    # Delegates to the AMR data class for this meter whose kwh_date_range
    # method does the same thing.
    def calculate(calculation_start_date, calculation_end_date, data_type = :kwh)
      amr_data = @meter.amr_data
      amr_data.kwh_date_range(calculation_start_date, calculation_end_date, data_type)
    rescue EnergySparksNotEnoughDataException
      nil
    end

    def meter_data_checker
      @meter_data_checker ||= Util::MeterDateRangeChecker.new(@meter, @end_date)
    end
  end
end
