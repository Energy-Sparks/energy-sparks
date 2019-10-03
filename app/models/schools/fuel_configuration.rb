module Schools
  class FuelConfiguration
    attr_reader :has_solar_pv, :has_storage_heaters, :has_gas, :has_electricity
    def initialize(has_solar_pv: false, has_storage_heaters: false, fuel_types_for_analysis: :none, has_gas: false, has_electricity: false)
      @has_solar_pv = has_solar_pv
      @has_storage_heaters = has_storage_heaters
      @fuel_types_for_analysis = fuel_types_for_analysis
      @has_gas = has_gas
      @has_electricity = has_electricity
    end

    def fuel_types_for_analysis
      @fuel_types_for_analysis.to_sym
    end

    def dual_fuel
      has_electricity && has_gas
    end

    def no_meters_with_validated_readings
      !has_electricity && !has_gas
    end
  end
end
