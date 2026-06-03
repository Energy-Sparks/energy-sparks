# frozen_string_literal: true

# rubocop:disable Lint/MissingSuper
module Baseload
  class SeasonalBaseloadService < BaseService
    include AnalysableMixin

    # Create a service that can calculate the seasonal baseload variation
    # for a specific meter
    #
    # To calculate baseload for a whole school provide the aggregate electricity
    # meter as the parameter.
    #
    # @param [Dashboard::Meter] analytics_meter the meter to use for calculations
    # @param [Date] asof_date the date to use as the basis for calculations
    #
    # @raise [EnergySparksUnexpectedStateException] if meter isn't an electricity meter
    def initialize(analytics_meter, asof_date = Time.zone.today)
      validate_meter(analytics_meter)
      @meter = analytics_meter
      @asof_date = asof_date
    end

    def enough_data?
      range_checker.one_years_data?
    end

    def data_available_from
      enough_data? ? nil : range_checker.date_when_one_years_data
    end

    # Calculate seasonal variation in baseload for this meter
    #
    # @return [Baseload::SeasonalVariation] the calculated variation
    # @raise [EnergySparksNotEnoughDataException] if the meter doesnt have a years worth of data
    def seasonal_variation
      raise EnergySparksNotEnoughDataException, "Needs 1 years amr data for as of date #{@asof_date}" unless enough_data?

      SeasonalVariation.new(
        winter_kw: baseload_analysis.winter_kw(@asof_date),
        summer_kw: baseload_analysis.summer_kw(@asof_date),
        percentage: baseload_analysis.percent_seasonal_variation(@asof_date)
      )
    end

    # Returns the costs over 1 year for the usage above the minimum baseload
    def estimated_costs
      raise EnergySparksNotEnoughDataException, "Needs 1 years amr data for as of date #{@asof_date}" unless enough_data?

      summer_kw = baseload_analysis.summer_kw(@asof_date)
      annual_cost_kwh = baseload_analysis.costs_of_baseload_above_minimum_kwh(@asof_date, summer_kw)

      # costs are using the current economic tariff (£current)
      # TODO: confirm whether this is correct
      CombinedUsageMetric.new(
        kwh: annual_cost_kwh,
        £: annual_cost_kwh * blended_baseload_rate_£current_per_kwh,
        co2: annual_cost_kwh * co2_per_kwh
      )
    end

    private

    def blended_baseload_rate_£current_per_kwh
      baseload_analysis.blended_baseload_tariff_rate_£_per_kwh(:£current, @asof_date)
    end

    def range_checker
      meter_date_range_checker(@meter, @asof_date)
    end
  end
end
# rubocop:enable Lint/MissingSuper
