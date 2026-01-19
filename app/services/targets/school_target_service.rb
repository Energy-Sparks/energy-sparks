module Targets
  class SchoolTargetService
    DEFAULT_ELECTRICITY_TARGET = 5.0
    DEFAULT_GAS_TARGET = 10.0
    DEFAULT_STORAGE_HEATER_TARGET = 5.0

    def initialize(school)
      @school = school
    end

    def self.targets_enabled?(school)
      school.enable_targets_feature?
    end

    def build_target
      @school.school_targets.build(
        start_date: target_start_date,
        target_date: target_end_date,
        electricity: electricity_target,
        gas: gas_target,
        storage_heaters: storage_heater_target
      )
    end

    def prompt_to_review_target?
      if @school.has_target? && @school.most_recent_target.suggest_revision?
        @school.most_recent_target.revised_fuel_types.each do |fuel_type|
          return true if @school.configuration.enough_data_to_set_target_for_fuel_type?(fuel_type)
        end
      end
    end

    def refresh_target(target)
      if target.revised_fuel_types.include?('storage_heater') && target.storage_heaters.nil?
        target.storage_heaters = DEFAULT_STORAGE_HEATER_TARGET
      end
      if target.revised_fuel_types.include?('electricity') && target.electricity.nil?
        target.electricity = DEFAULT_ELECTRICITY_TARGET
      end
      if target.revised_fuel_types.include?('gas') && target.gas.nil?
        target.gas = DEFAULT_GAS_TARGET
      end
    end

    def enough_data?
      # always return true for v2
      true
    end

    def enough_data_for_electricity?
      @school.has_electricity?
    end

    def enough_data_for_gas?
      @school.has_gas?
    end

    def enough_data_for_storage_heater?
      @school.has_storage_heaters?
    end

    private

    def target_end_date
      target_start_date.next_year
    end

    def target_start_date
      @target_start_date ||= determine_target_start_date
    end

    def default_target_start_date
      Time.zone.today.beginning_of_month
    end

    # Some schools are running slightly behind on their data, but do have enough data
    # to set a target. In this case we're rolling back the target start date to the
    # month of the last validated reading. But only if they're not using an annual
    # estimate.
    #
    # However if there's a previous target, then we just default to when that ended
    def determine_target_start_date
      return most_recent_target.target_date if most_recent_target.present?
      target_start_date = default_target_start_date
      [:electricity, :gas, :storage_heater].each do |fuel_type|
        service = target_service(aggregate_school, fuel_type)
        # ignore if school doesnt have this fuel type, we have enough data to set a target, and we're not using, or needing to use an estimate
        if service.meter_present? && service.enough_data_to_set_target? && !service.annual_kwh_estimate_required?
          suggested_date = service.default_target_start_date
          target_start_date = suggested_date if suggested_date.present? && suggested_date < target_start_date
        end
      end
      target_start_date
    end

    def electricity_target
      return nil unless @school.has_electricity?
      most_recent_target.present? ? most_recent_target.electricity : DEFAULT_ELECTRICITY_TARGET
    end

    def gas_target
      return nil unless @school.has_gas?
      most_recent_target.present? ? most_recent_target.gas : DEFAULT_GAS_TARGET
    end

    def storage_heater_target
      return nil unless @school.has_storage_heaters? || @school.indicated_has_storage_heaters?
      most_recent_target.present? ? most_recent_target.storage_heaters : DEFAULT_STORAGE_HEATER_TARGET
    end

    def most_recent_target
      @most_recent_target ||= @school.most_recent_target
    end

    def aggregate_school
      @aggregate_school ||= AggregateSchoolService.new(@school).aggregate_school
    end

    def target_service(aggregate_school, fuel_type)
      TargetsService.new(aggregate_school, fuel_type)
    end
  end
end
