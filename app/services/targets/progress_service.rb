module Targets
  class ProgressService
    def initialize(school)
      @school = school
    end

    def display_progress_for_fuel_type?(fuel_type)
      has_fuel_type_and_target?(fuel_type) &&
        @school.configuration.enough_data_to_set_target_for_fuel_type?(fuel_type)
    end

    def progress_summary
      if Targets::SchoolTargetService.targets_enabled?(@school) && target.present?
        #create from data in school target
        target.to_progress_summary
      end
    end

    private

    def has_fuel_type?(fuel_type)
      @school.send("has_#{fuel_type}?".to_sym)
    end

    def has_fuel_type_and_target?(fuel_type)
      has_fuel_type?(fuel_type) && has_target_for_fuel_type?(fuel_type)
    end

    def target
      @school.most_recent_target
    end

    def has_target_for_fuel_type?(fuel_type)
      return false unless target.present?
      case fuel_type
      when :electricity
        target.electricity.present?
      when :gas
        target.gas.present?
      when :storage_heater, :storage_heaters
        target.storage_heaters.present?
      else
        false
      end
    end
  end
end
