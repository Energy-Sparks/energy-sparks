# frozen_string_literal: true

require 'dashboard'

module Schools
  class GenerateFuelConfiguration
    def initialize(school, configuration = school.configuration)
      @school = school
      @configuration = configuration
    end

    def generate
      @configuration.update(gas: has_gas?, electricity: has_electricity?)

      FuelConfiguration.new(
        has_solar_pv: @school.has_solar_pv?,
        has_storage_heaters: @school.has_storage_heaters?,
        dual_fuel: is_school_dual_fuel?,
        fuel_types_for_analysis: fuel_types_for_analysis,
        no_meters_with_validated_readings: no_meters_with_validated_readings?,
        has_gas: has_gas?
      )
    end

    private

    def fuel_types_for_analysis
      if is_school_dual_fuel?
        dual_fuel_fuel_type
      elsif has_electricity?
        electricity_fuel_type
      elsif has_gas?
        :gas_only
      else
        :none
      end
    end

    def has_gas?
      @school.meters_with_validated_readings(:gas).exists?
    end

    def has_electricity?
      @school.meters_with_validated_readings(:electricity).exists?
    end

    def no_meters_with_validated_readings?
      @school.meters_with_validated_readings.empty?
    end

    def is_school_dual_fuel?
      has_gas? && has_electricity?
    end

    def dual_fuel_fuel_type
      @school.has_solar_pv? ? :electric_and_gas_and_solar_pv : :electric_and_gas
    end

    def electricity_fuel_type
      @school.has_storage_heaters? ? :electric_and_storage_heaters : :electric_only
    end
  end
end
