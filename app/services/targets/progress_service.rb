module Targets
  class ProgressService
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
      target_progress.present? ? target_progress.cumulative_usage_kwh[this_month] : nil
    end

    #TEMPORARY
    def setup_management_table
      dashboard_table = @school.latest_management_dashboard_tables.first
      return nil unless dashboard_table.present?
      return dashboard_table.table unless @school.has_target? && EnergySparks::FeatureFlags.active?(:school_targets)
      dashboard_table.table.each do |row|
        row.insert(-2, "Target progress") if row[0] == ""
        row.insert(-2, format_for_table(cumulative_progress(:electricity))) if row[0] == "Electricity"
        row.insert(-2, format_for_table(cumulative_progress(:gas))) if row[0] == "Gas"
        row.insert(-2, format_for_table(cumulative_progress(:storage_heater))) if row[0] == "Storage heaters"
      end
    end

    private

    def this_month
      Time.zone.now.strftime("%b")
    end

    def has_fuel_type?(fuel_type)
      @school.send("has_#{fuel_type}?".to_sym)
    end

    def format_for_table(value)
      if value.nil?
        "not enough data"
      else
        FormatEnergyUnit.format(:relative_percent, value, :html, false, true, :target)
      end
    end

    def target_progress(fuel_type)
      return nil unless has_fuel_type?(fuel_type)
      begin
        @progress_by_fuel_type[fuel_type] ||= target_service(fuel_type).progress
      rescue => e
        Rollbar.error(e)
        return nil
      end
    end

    def target_service(fuel_type)
      TargetsService.new(@aggregated_school, fuel_type)
    end
  end
end
