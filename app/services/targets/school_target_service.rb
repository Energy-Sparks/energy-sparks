module Targets
  class SchoolTargetService
    DEFAULT_ELECTRICITY_TARGET = 5.0
    DEFAULT_GAS_TARGET = 5.0
    DEFAULT_STORAGE_HEATER_TARGET = 5.0

    def initialize(school)
      @school = school
    end

    def self.targets_enabled?(school)
      EnergySparks::FeatureFlags.active?(:school_targets) && school.enable_targets_feature?
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
          return true if enough_data_for_fuel_type?(fuel_type.to_sym)
        end
      end
    end

    def refresh_target(target)
      if target.revised_fuel_types.include?("storage heater") && target.storage_heaters.nil?
        target.storage_heaters = DEFAULT_STORAGE_HEATER_TARGET
      end
      if target.revised_fuel_types.include?("electricity") && target.electricity.nil?
        target.electricity = DEFAULT_ELECTRICITY_TARGET
      end
      if target.revised_fuel_types.include?("gas") && target.gas.nil?
        target.gas = DEFAULT_GAS_TARGET
      end
    end

    def enough_data?
      return true if enough_data_for_electricity?
      return true if enough_data_for_gas?
      return true if enough_data_for_storage_heater?
      return false
    end

    def enough_data_for_electricity?
      @school.has_electricity? && enough_data_for_fuel_type?(:electricity)
    end

    def enough_data_for_gas?
      @school.has_gas? && enough_data_for_fuel_type?(:gas)
    end

    def enough_data_for_storage_heater?
      @school.has_storage_heaters? && enough_data_for_fuel_type?(:storage_heater)
    end

    private

    def default_target_start_date
      Time.zone.today.beginning_of_month
    end

    def target_end_date
      target_start_date.next_year
    end

    def target_start_date
      @target_start_date ||= determine_target_start_date
    end

    #some schools are running slightly behind on their data, but do have enough data
    #to set a target. In this case we're rolling back the target start date to the
    #month of the last validated reading. But only if they're not using an annual
    #estimate.
    def determine_target_start_date
      latest_reading_date = latest_reading_date_all_fuel_types
      if latest_reading_date < default_target_start_date
        return latest_reading_date.beginning_of_month
      else
        default_target_start_date
      end
    end

    #Find latest reading data across fuel types, ignoring fuel types which
    #the school doesn't have, or where we're using an annual estimate
    #
    #Uses the aggregate school and meter as we already have the data
    #in-memory at this point
    def latest_reading_date_all_fuel_types
      latest_reading = Time.zone.today
      [:electricity, :gas, :storage_heater].each do |fuel_type|
        #check for annual estimate attribute
        unless using_annual_estimate?(fuel_type)
          aggregate_meter = aggregate_school.aggregate_meter(fuel_type)
          #school has this fuel type?
          if aggregate_meter.present?
            latest_data = aggregate_meter.amr_data.end_date
            latest_reading = latest_data if latest_data.present? && latest_data < latest_reading
          end
        end
      end
      latest_reading
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

    def enough_data_for_fuel_type?(fuel_type)
      target_service(aggregate_school, fuel_type).enough_data_to_set_target?
    end

    def aggregate_school
      @aggregate_school ||= AggregateSchoolService.new(@school).aggregate_school
    end

    def using_annual_estimate?(fuel_type)
      target_service(aggregate_school, fuel_type).annual_kwh_estimate?
    end

    def target_service(aggregate_school, fuel_type)
      ::TargetsService.new(aggregate_school, fuel_type)
    end
  end
end
