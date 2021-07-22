module Schools
  class ProgressController < ApplicationController
    load_and_authorize_resource :school

    include SchoolAggregation

    before_action :check_aggregated_school_in_cache, only: :index

    def index
      redirect_to electricity_school_progress_index_path
    end

    def electricity
      index_for(:electricity)
    end

    def gas
      index_for(:gas)
    end

    def storage_heaters
      index_for(:storage_heaters)
    end

    private

    def index_for(fuel_type)
      @current_target = @school.current_target
      @progress = TargetsService.new(aggregate_school, fuel_type).progress
      render :index
    end
  end
end
