module Targets
  class GenerateProgressService
    def initialize(school, aggregated_school)
      @school = school
      @aggregated_school = aggregated_school
      @progress_by_fuel_type = {}
    end

    def cumulative_progress(fuel_type)
      target_progress = target_progress(fuel_type)
      target_progress.present? ? target_progress.current_cumulative_performance_versus_synthetic_last_year : nil
    end

    def current_monthly_target(fuel_type)
      target_progress = target_progress(fuel_type)
      target_progress.present? ? target_progress.cumulative_targets_kwh[this_month] : nil
    end

    def current_monthly_usage(fuel_type)
      target_progress = target_progress(fuel_type)
      target_progress.present? ? target_progress.current_cumulative_usage_kwh : nil
    end

    def generate!
      if Targets::SchoolTargetService.targets_enabled?(@school) && target.present?
        target.update!(
          electricity_progress: fuel_type_progress(:electricity),
          gas_progress: fuel_type_progress(:gas),
          storage_heaters_progress: fuel_type_progress(:storage_heaters),
          report_last_generated: Time.zone.now
        )
        return target
      end
    end

    private

    def can_generate_fuel_type?(fuel_type)
      has_fuel_type_and_target?(fuel_type) &&
        @school.configuration.enough_data_to_set_target_for_fuel_type?(fuel_type)
    end

    def fuel_type_progress(fuel_type)
      if can_generate_fuel_type?(fuel_type)
        Targets::FuelProgress.new(
          fuel_type: fuel_type,
          progress: cumulative_progress(fuel_type),
          usage: current_monthly_usage(fuel_type),
          target: current_monthly_target(fuel_type),
          recent_data: target_service(fuel_type).recent_data?
        )
      else
        {}
      end
    end

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

    def this_month
      Time.zone.now.strftime("%b")
    end

    def target_progress(fuel_type)
      return nil unless has_fuel_type_and_target?(fuel_type)
      begin
        @progress_by_fuel_type[fuel_type] ||= target_service(fuel_type).progress
      rescue => e
        Rollbar.error(e, school_id: @school.id, school: @school.name, fuel_type: fuel_type)
        return nil
      end
    end

    def target_service(fuel_type)
      TargetsService.new(@aggregated_school, fuel_type)
    end
  end
end
