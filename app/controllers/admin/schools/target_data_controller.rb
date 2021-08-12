module Admin
  module Schools
    class TargetDataController < AdminController
      load_and_authorize_resource :school

      include SchoolAggregation

      before_action :check_aggregated_school_in_cache, only: :show

      def show
        @electricity_service = @school.has_electricity? ? ::TargetsService.new(aggregate_school, :electricity) : nil
        @gas_service = @school.has_gas? ? ::TargetsService.new(aggregate_school, :gas) : nil
        @storage_heater_service = @school.has_storage_heaters? ? ::TargetsService.new(aggregate_school, :storage_heaters) : nil
      end
    end
  end
end
