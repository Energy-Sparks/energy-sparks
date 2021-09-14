module Targets
  class ProgressService
    def initialize(school, aggregated_school)
      @school = school
      @aggregated_school = aggregated_school
      @progress_by_fuel_type = {}
    end

    def display_progress_for_fuel_type?(fuel_type)
      has_fuel_type_and_target?(fuel_type) && target_service(fuel_type).enough_data_to_set_target?
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

    #TEMPORARY
    def setup_management_table
      dashboard_table = @school.latest_management_dashboard_tables.first
      return nil unless dashboard_table.present?
      return dashboard_table.table unless Targets::SchoolTargetService.targets_enabled?(@school) && @school.has_target?
      dashboard_table.table.each do |row|
        row.insert(-2, "Target progress") if row[0] == ""
        row.insert(-2, management_table_entry(:electricity)) if row[0] == "Electricity"
        row.insert(-2, management_table_entry(:gas)) if row[0] == "Gas"
        row.insert(-2, management_table_entry(:storage_heater)) if row[0] == "Storage heaters"
      end
    end

    private

    def has_target_for_fuel_type?(fuel_type)
      target = @school.most_recent_target
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

    def has_fuel_type?(fuel_type)
      @school.send("has_#{fuel_type}?".to_sym)
    end

    def has_fuel_type_and_target?(fuel_type)
      has_fuel_type?(fuel_type) && has_target_for_fuel_type?(fuel_type)
    end

    def management_table_entry(fuel_type)
      return "-" unless has_fuel_type_and_target?(fuel_type)
      return "not enough data" unless target_service(fuel_type).enough_data_to_set_target?
      format_for_table(cumulative_progress(fuel_type))
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
