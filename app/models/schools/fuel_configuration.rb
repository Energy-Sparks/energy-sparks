# frozen_string_literal: true

module Schools
  class FuelConfiguration
    attr_reader :has_solar_pv, :has_storage_heaters, :dual_fuel, :fuel_types_for_analysis, :no_meters_with_validated_readings, :has_gas
    def initialize(has_solar_pv: false, has_storage_heaters: false, dual_fuel: false, fuel_types_for_analysis:, no_meters_with_validated_readings: true, has_gas: false)
      @has_solar_pv = has_solar_pv
      @has_storage_heaters = has_storage_heaters
      @dual_fuel = dual_fuel
      @fuel_types_for_analysis = fuel_types_for_analysis
      @no_meters_with_validated_readings = no_meters_with_validated_readings
      @has_gas = has_gas
    end
  end
end
