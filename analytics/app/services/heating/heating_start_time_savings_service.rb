# frozen_string_literal: true

require 'ostruct'

module Heating
  class HeatingStartTimeSavingsService < BaseService
    # Create a service capable of calculating one year savings if heating
    # times were optmised
    #
    # @param [MeterCollection] meter_collection the school to be analysed
    # @param [Date] asof_date the date to use as the basis for calculations
    #
    # @raise [EnergySparksUnexpectedStateException] if the schools doesnt have gas meters
    # @raise [EnergySparksUnexpectedStateException] if the school does not use gas for heating
    def initialize(meter_collection, asof_date = Date.today)
      validate_meter_collection(meter_collection)
      super(meter_collection, asof_date)
    end

    def enough_data?
      meter_date_range_checker.at_least_x_days_data?(ONE_WEEK) && super
    end

    # Calculate the percentage of annual gas consumption that would be saved
    # if heating start times were optimised.
    #
    # This looks at up to a full year of data
    def percentage_of_annual_gas
      saving_as_percentage_of_annual_gas
    end

    # Calculate the estimated savings if the heating start times were aligned
    # with our recommendations.
    #
    # This looks at up to a full year of data
    #
    # @return [CombinedUsageMetric] the estimated savings
    def estimated_savings
      CombinedUsageMetric.new(
        kwh: one_year_saving(:kwh),
        £: one_year_saving(:£current),
        co2: one_year_saving(:co2)
      )
    end

    private

    def saving_as_percentage_of_annual_gas
      _saving, percentage = heating_model.one_year_saving_from_better_boiler_start_time(@asof_date, :kwh)
      percentage
    end

    def one_year_saving(datatype)
      saving, _percentage = heating_model.one_year_saving_from_better_boiler_start_time(@asof_date, datatype)
      saving
    end
  end
end
