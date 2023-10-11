module Targets
  class GenerateEstimatedUsage
    def initialize(school, aggregated_meter_collection)
      @school = school
      @aggregated_meter_collection = aggregated_meter_collection
    end

    def generate
      estimates = {}
      add_estimate_for_fuel_type(estimates, :electricity) if @school.has_electricity?
      add_estimate_for_fuel_type(estimates, :gas) if @school.has_gas?
      add_estimate_for_fuel_type(estimates, :storage_heater) if @school.has_storage_heaters?
      estimates
    end

    private

    def add_estimate_for_fuel_type(estimates, fuel_type)
      estimate = target_service(fuel_type).annual_kwh_estimate_kwh
      estimates[fuel_type] = estimate if estimate.present?
    rescue StandardError => e
      Rollbar.error(e, scope: :add_estimate_for_fuel_type, school_id: @school.id, school: @school.name, fuel_type: fuel_type)
    end

    def target_service(fuel_type)
      ::TargetsService.new(@aggregated_meter_collection, fuel_type)
    end
  end
end
