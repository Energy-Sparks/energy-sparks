module Schools
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
      table = @school.latest_management_dashboard_tables.first.table
      table.each do |row|
        row.insert(-2, "Target progress") if row[0] == ""
        row.insert(-2, FormatEnergyUnit.format(:relative_percent, electricity_progress, :html, false, true, :target)) if row[0] == "Electricity"
        row.insert(-2, FormatEnergyUnit.format(:relative_percent, gas_progress, :html, false, true, :target)) if row[0] == "Gas"
      end
    end

    private

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
