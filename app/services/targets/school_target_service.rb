module Targets
  class SchoolTargetService
    DEFAULT_ELECTRICITY_TARGET = 5.0
    DEFAULT_GAS_TARGET = 5.0
    DEFAULT_STORAGE_HEATERS_TARGET = 5.0

    def initialize(school)
      @school = school
    end

    def build_target
      @school.school_targets.build(
        start_date: target_start_date,
        target_date: target_end_date,
        electricity: electricity_target,
        gas: gas_target,
        storage_heaters: storage_heaters_target
      )
    end

    def enough_data?
      aggregate_school = AggregateSchoolService.new(@school).aggregate_school
      return true if @school.has_electricity? && target_service(aggregate_school, :electricity).enough_data_to_set_target?
      return true if @school.has_gas? && target_service(aggregate_school, :gas).enough_data_to_set_target?
      return true if @school.has_storage_heaters? && target_service(aggregate_school, :storage_heaters).enough_data_to_set_target?
      return false
    end

    private

    def target_start_date
      Time.zone.today.beginning_of_month
    end

    def target_end_date
      Time.zone.today.beginning_of_month.next_year
    end

    def electricity_target
      most_recent_target.present? ? most_recent_target.electricity : DEFAULT_ELECTRICITY_TARGET
    end

    def gas_target
      most_recent_target.present? ? most_recent_target.gas : DEFAULT_GAS_TARGET
    end

    def storage_heaters_target
      most_recent_target.present? ? most_recent_target.storage_heaters : DEFAULT_STORAGE_HEATERS_TARGET
    end

    def most_recent_target
      @most_recent_target ||= @school.most_recent_target
    end

    def target_service(aggregate_school, fuel_type)
      ::TargetsService.new(aggregate_school, fuel_type)
    end
  end
end
