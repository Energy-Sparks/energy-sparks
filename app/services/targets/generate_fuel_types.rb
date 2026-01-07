# frozen_string_literal: true

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
      rescue Targets::TargetsService::TargetDates::TargetDateBeforeFirstMeterStartDate
        # noop
      rescue StandardError => e
        Rollbar.error(e, scope: :fuel_types_with_enough_data, school_id: @school.id, school: @school.name)
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

    def enough_data_for_fuel_type?(fuel_type)
      target_service(fuel_type).enough_data_to_set_target?
    end

    def target_service(fuel_type)
      TargetsService.new(@aggregated_meter_collection, fuel_type)
    end
  end
end
