module Targets
  class GenerateProgressService
    def initialize(school, aggregated_school)
      @school = school
      @aggregated_school = aggregated_school
      @progress_by_fuel_type = {}
    end

    def cumulative_progress(fuel_type)
      target_progress = progress_report(fuel_type)
      target_progress.present? ? target_progress.cumulative_performance_versus_synthetic_last_year[reporting_month] : nil
    end

    def current_monthly_target(fuel_type)
      target_progress = progress_report(fuel_type)
      target_progress.present? ? target_progress.cumulative_targets_kwh[reporting_month] : nil
    end

    def current_monthly_usage(fuel_type)
      target_progress = progress_report(fuel_type)
      target_progress.present? ? target_progress.cumulative_usage_kwh[reporting_month] : nil
    end

    def generate!
      if Targets::SchoolTargetService.targets_enabled?(@school) && target.present?
        target.update!(
          electricity_progress: fuel_type_progress(:electricity),
          electricity_report: progress_report(:electricity),
          gas_progress: fuel_type_progress(:gas),
          gas_report: progress_report(:gas),
          storage_heaters_progress: fuel_type_progress(:storage_heaters),
          storage_heaters_report: progress_report(:storage_heaters),
          report_last_generated: Time.zone.now
        )
        return target
      end
    end

    private

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

    def can_generate_fuel_type?(fuel_type)
      has_fuel_type_and_target?(fuel_type) && enough_data_to_calculate_target?(fuel_type)
    end

    def has_fuel_type_and_target?(fuel_type)
      has_fuel_type?(fuel_type) && has_target_for_fuel_type?(fuel_type)
    end

    def has_fuel_type?(fuel_type)
      @school.send("has_#{fuel_type}?".to_sym)
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

    def target
      @school.most_recent_target
    end

    def reporting_month
      #if target is expired, then use the final month, otherwise report on
      #current progress
      if target.expired?
        target.target_date.prev_month.beginning_of_month
      else
        Time.zone.today.beginning_of_month
      end
    end

    def progress_report(fuel_type)
      return nil unless has_fuel_type_and_target?(fuel_type)
      return nil unless enough_data_to_calculate_target?(fuel_type)
      target_progress(fuel_type)
    end

    def target_progress(fuel_type)
      begin
        @progress_by_fuel_type[fuel_type] ||= target_service(fuel_type).progress
      rescue => e
        Rollbar.error(e, scope: :generate_progress, school_id: @school.id, school: @school.name, fuel_type: fuel_type)
        return nil
      end
    end

    def enough_data_to_calculate_target?(fuel_type)
      begin
        target_service(fuel_type).enough_data_to_set_target?
      rescue => e
        Rollbar.error(e, scope: :generate_progress, school_id: @school.id, school: @school.name, fuel_type: fuel_type)
        false
      end
    end

    def target_service(fuel_type)
      TargetsService.new(@aggregated_school, fuel_type)
    end
  end
end
