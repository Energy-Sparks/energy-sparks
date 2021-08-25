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

    def storage_heater
      @school.has_storage_heaters? ? index_for(:storage_heater) : missing(:storage_heater)
    end

    private

    def index_for(fuel_type)
      @fuel_type = fuel_type
      @current_target = @school.current_target
      @show_storage_heater_notes = show_storage_heater_notes(@school, @fuel_type)
      begin
        service = TargetsService.new(aggregate_school, @fuel_type)
        @progress = service.progress
        #@debug_content = service.analytics_debug_info if current_user.analytics?
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

    def show_storage_heater_notes(school, fuel_type)
      fuel_type == :electricity && school.has_storage_heaters?
    end
  end
end
