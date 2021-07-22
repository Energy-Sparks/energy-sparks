require 'benchmark'

module Schools
  class ProgressController < ApplicationController
    load_and_authorize_resource :school

    include SchoolAggregation

    before_action :check_aggregated_school_in_cache, only: :index

    def index
      redirect_to electricity_school_progress_index_path
    end

    def electricity
      @school.has_electricity? ? index_for(:electricity) : missing(:electricity)
    end

    def gas
      @school.has_gas? ? index_for(:gas) : missing(:gas)
    end

    def storage_heaters
      @school.has_storage_heaters? ? index_for(:storage_heaters) : missing(:storage_heaters)
    end

    private

    def index_for(fuel_type)
      @fuel_type = fuel_type
      @current_target = @school.current_target
      begin
        @progress = TargetsService.new(aggregate_school, @fuel_type).progress
      rescue => e
        Rollbar.error(e)
        flash[:error] = e.message
      end
      render :index
    end

    def missing(fuel_type)
      @fuel_type = fuel_type
      render :missing
    end
  end
end
