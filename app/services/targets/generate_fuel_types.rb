module Targets
  class GenerateFuelTypes
    def initialize(school, aggregated_meter_collection)
      @school = school
      @aggregated_meter_collection = aggregated_meter_collection
    end

    def fuel_types_with_enough_data
      fuel_types = []
      begin
        fuel_types << 'electricity' if enough_data_for_electricity?
        fuel_types << 'gas' if enough_data_for_gas?
        fuel_types << 'storage_heater' if enough_data_for_storage_heater?
      rescue StandardError => e
        Rollbar.error(e, scope: :fuel_types_with_enough_data, school_id: @school.id, school: @school.name)
      end
      fuel_types
    end

    def suggest_estimates_for_fuel_types
      fuel_types = []
      begin
        fuel_types << 'electricity' if suggest_estimate_for_electricity?
        fuel_types << 'gas' if suggest_estimate_for_gas?
        fuel_types << 'storage_heater' if suggest_estimate_for_storage_heater?
      rescue StandardError => e
        Rollbar.error(e, scope: :suggest_estimates_for_fuel_types, school_id: @school.id, school: @school.name)
      end
      fuel_types
    end

    private

    def enough_data_for_electricity?
      @school.has_electricity? && enough_data_for_fuel_type?(:electricity)
    end

    def enough_data_for_gas?
      @school.has_gas? && enough_data_for_fuel_type?(:gas)
    end

    def enough_data_for_storage_heater?
      @school.has_storage_heaters? && enough_data_for_fuel_type?(:storage_heater)
    end

    def suggest_estimate_for_electricity?
      @school.has_electricity? && suggest_use_of_estimate?(:electricity)
    end

    def suggest_estimate_for_gas?
      @school.has_gas? && suggest_use_of_estimate?(:gas)
    end

    def suggest_estimate_for_storage_heater?
      @school.has_storage_heaters? && suggest_use_of_estimate?(:storage_heater)
    end

    def suggest_use_of_estimate?(fuel_type)
      target_service(fuel_type).suggest_use_of_estimate?
    end

    def enough_data_for_fuel_type?(fuel_type)
      target_service(fuel_type).enough_data_to_set_target?
    end

    def target_service(fuel_type)
      ::TargetsService.new(@aggregated_meter_collection, fuel_type)
    end
  end
end
