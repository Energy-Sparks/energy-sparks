require 'benchmark'

module Schools
  class ProgressController < ApplicationController
    load_and_authorize_resource :school

    include SchoolAggregation
    include SchoolProgress

    before_action :check_aggregated_school_in_cache, only: :index
    before_action :redirect_if_disabled

    def index
      redirect_to electricity_school_progress_index_path
    end

    def electricity
      progress_service.display_progress_for_fuel_type?(:electricity) ? index_for(:electricity) : missing(:electricity)
    end

    def gas
      progress_service.display_progress_for_fuel_type?(:gas) ? index_for(:gas) : missing(:gas)
    end

    def storage_heater
      progress_service.display_progress_for_fuel_type?(:storage_heaters) ? index_for(:storage_heater) : missing(:storage_heater)
    end

    private

    def index_for(fuel_type)
      @fuel_type = fuel_type
      @current_target = @school.current_target
      @show_storage_heater_notes = show_storage_heater_notes(@school, @fuel_type)
      begin
        service = TargetsService.new(aggregate_school, @fuel_type)
        @recent_data = service.recent_data?
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

    def progress_service
      Targets::ProgressService.new(@school, aggregate_school)
    end
  end
end
