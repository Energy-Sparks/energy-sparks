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
      @school.has_gas? ? progress(school, :gas) : nil
    end

    def storage_heater_progress
      @school.has_storage_heaters? ? progress(school, :storage_heaters) : nil
    end

    private

    def progress(fuel_type)
      begin
        return TargetsService.new(@aggregate_school, fuel_type).progress.current_cumulative_performance_versus_synthetic_last_year
      rescue => e
        Rollbar.error(e)
        return nil
      end
    end
  end
end
