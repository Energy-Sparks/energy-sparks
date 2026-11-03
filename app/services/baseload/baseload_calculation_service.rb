# frozen_string_literal: true

module Baseload
  # This illustrates future direction of analytics interfaces, with
  # the application code calling service classes which delegate
  # to underlying supporting code in the analytics
  #
  # For both the initial and later versions, we'll need
  # to be careful to preserve any checks around whether
  # a school or meter has enough data in order to run a calculation
  #
  # Other sanity checks, e.g. does this school have electricity can
  # be done in the calling code.
  class BaseloadCalculationService < BaseService
    include AnalysableMixin
    KWH_SAVING_FOR_EACH_ONE_KW_REDUCTION_IN_BASELOAD = 8760.0 # Number of hours in a year: 365.0 * 24.0 = 8760.0

    # Create a service that can calculate the baseload for a specific meter
    #
    # To calculate baseload for a whole school provide the aggregate electricity
    # meter as the parameter.
    #
    # @param [Dashboard::Meter] analytics_meter the meter to use for calculations
    # @param [Date] asof_date the date to use as the basis for calculations
    #
    # @raise [EnergySparksUnexpectedStateException] if meter isn't an electricity meter
    def initialize(analytics_meter, asof_date = Date.today)
      super()
      validate_meter(analytics_meter)
      @meter = analytics_meter
      @asof_date = asof_date
    end

    def enough_data?
      range_checker.at_least_x_days_data?(DEFAULT_DAYS_OF_DATA_REQUIRED)
    end

    def data_available_from
      enough_data? ? nil : range_checker.date_when_enough_data_available(DEFAULT_DAYS_OF_DATA_REQUIRED)
    end

    #
    # co2_per_kwh = Costs::BlendedRateCalculator.new(@meter.meter_collection.aggregated_electricity_meters).blended_co2_per_kwh
    def saving_through_1_kw_reduction_in_baseload
      CombinedUsageMetric.new(
        kwh: KWH_SAVING_FOR_EACH_ONE_KW_REDUCTION_IN_BASELOAD,
        co2: co2_per_kwh * KWH_SAVING_FOR_EACH_ONE_KW_REDUCTION_IN_BASELOAD,
        £: baseload_analysis.blended_baseload_tariff_rate_£_per_kwh(:£current, @asof_date) * KWH_SAVING_FOR_EACH_ONE_KW_REDUCTION_IN_BASELOAD
      )
    end

    # Calculate average baseload for this meter for the specified period
    #
    # Supported periods are: :year, or :week
    #
    # @param [Symbol] period the period over which to calculate the average
    def average_baseload_kw(period: :year)
      case period
      when :year
        baseload_analysis.average_annual_baseload_kw(@asof_date)
      when :week
        baseload_analysis.average_baseload_last_week_kw(@asof_date)
      else
        raise 'Invalid period'
      end
    end

    # Calculate the expected annual energy usage based on the
    # average baseload for this school over the last year
    #
    # The usage returns include kwh, co2 emissions and £ costs.
    # The percent value is % of total annual usage
    #
    # @return [CombinedUsageMetric] the calculated usage
    def annual_baseload_usage(include_percentage: false)
      metric = CombinedUsageMetric.new(
        kwh: average_baseload_last_year_kwh,
        £: average_baseload_last_year_£,
        co2: average_baseload_last_year_co2
      )
      metric.percent = baseload_percent_annual_consumption if include_percentage
      metric
    end

    private

    def average_baseload_last_year_kwh
      @average_baseload_last_year_kwh ||= baseload_analysis.annual_average_baseload_kwh(@asof_date)
    end

    def average_baseload_last_year_£
      baseload_analysis.scaled_annual_baseload_cost_£(:£, @asof_date)
    end

    def average_baseload_last_year_co2
      kwh = average_baseload_last_year_kwh
      kwh * co2_per_kwh
    end

    def baseload_percent_annual_consumption
      @baseload_percent_annual_consumption ||= baseload_analysis.baseload_percent_annual_consumption(@asof_date)
    end

    def meter_collection
      @meter.meter_collection
    end

    def range_checker
      meter_date_range_checker(@meter, @asof_date)
    end
  end
end
