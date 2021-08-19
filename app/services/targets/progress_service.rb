module Targets
  class ProgressService
    def initialize(school, aggregated_school)
      @school = school
      @aggregated_school = aggregated_school
    end

    def electricity_progress
      @school.has_electricity? ? progress(:electricity) : nil
    end

    def gas_progress
      @school.has_gas? ? progress(:gas) : nil
    end

    def storage_heater_progress
      @school.has_storage_heaters? ? progress(:storage_heaters) : nil
    end

    #TEMPORARY
    def setup_management_table
      dashboard_table = @school.latest_management_dashboard_tables.first
      return nil unless dashboard_table.present?
      puts EnergySparks::FeatureFlags.active?(:school_targets).inspect
      return dashboard_table.table unless EnergySparks::FeatureFlags.active?(:school_targets)
      puts "ON"
      dashboard_table.table.each do |row|
        row.insert(-2, "Target progress") if row[0] == ""
        row.insert(-2, format_for_table(electricity_progress)) if row[0] == "Electricity"
        row.insert(-2, format_for_table(gas_progress)) if row[0] == "Gas"
        row.insert(-2, format_for_table(storage_heater_progress)) if row[0] == "Storage heaters"
      end
    end

    private

    def format_for_table(value)
      if value.nil?
        "not enough data"
      else
        FormatEnergyUnit.format(:relative_percent, value, :html, false, true, :target)
      end
    end

    def progress(fuel_type)
      begin
        return TargetsService.new(@aggregated_school, fuel_type).progress.current_cumulative_performance_versus_synthetic_last_year
      rescue => e
        Rollbar.error(e)
        return nil
      end
    end
  end
end
