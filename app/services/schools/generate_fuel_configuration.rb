# frozen_string_literal: true

require 'dashboard'

module Schools
  class GenerateFuelConfiguration
    def initialize(aggregated_meter_collection)
      @aggregated_meter_collection = aggregated_meter_collection
    end

    def generate
      FuelConfiguration.new(
        has_solar_pv: @aggregated_meter_collection.solar_pv_panels?,
        has_storage_heaters: @aggregated_meter_collection.storage_heaters?,
        fuel_types_for_analysis: @aggregated_meter_collection.report_group,
        has_gas: @aggregated_meter_collection.gas?,
        has_electricity: @aggregated_meter_collection.electricity?
      )
    end
  end
end
