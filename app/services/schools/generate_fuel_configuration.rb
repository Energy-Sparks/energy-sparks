require 'dashboard'

module Schools
  class GenerateFuelConfiguration
    def initialize(school)
      @school = school
    end

    def generate
      FuelConfiguration.new(
        has_solar_pv: @school.has_solar_pv?,
        has_storage_heaters: @school.has_storage_heaters?,
        dual_fuel: is_school_dual_fuel?,
        fuel_types_for_analysis: fuel_types_for_analysis,
        no_meters_with_validated_readings: no_meters_with_validated_readings?
        )
    end

  private

    def fuel_types_for_analysis
      if is_school_dual_fuel?
        dual_fuel_fuel_type
      elsif @school.meters_with_validated_readings(:electricity).exists?
        electricity_fuel_type
      elsif @school.meters_with_validated_readings(:gas).exists?
        :gas_only
      else
        :none
      end
    end

    def no_meters_with_validated_readings?
      @school.meters_with_validated_readings.empty?
    end

    def is_school_dual_fuel?
      @school.meters_with_validated_readings(:gas).exists? && @school.meters_with_validated_readings(:electricity).exists?
    end

    def dual_fuel_fuel_type
      @school.has_solar_pv? ? :electric_and_gas_and_solar_pv : :electric_and_gas
    end

    def electricity_fuel_type
      @school.has_storage_heaters? ? :electric_and_storage_heaters : :electric_only
    end
  end
end
