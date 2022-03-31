require 'benchmark'

module Schools
  class ProgressController < ApplicationController
    load_and_authorize_resource :school

    include SchoolAggregation
    include SchoolProgress

    skip_before_action :authenticate_user!
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
      @school_target = @school.most_recent_target
      authorize! :show, @school_target
      @show_storage_heater_notes = show_storage_heater_notes(@school, @school_target, @fuel_type)
      begin
        service = TargetsService.new(aggregate_school, @fuel_type)
        @recent_data = service.recent_data?
        @progress = service.progress
        @suggest_estimate_important = suggest_estimate_for_fuel_type?(@fuel_type, check_data: true)
        @debug_content = service.analytics_debug_info if current_user.present? && current_user.analytics?
      rescue => e
        Rails.logger.error e
        Rails.logger.error e.backtrace.join("\n")
        Rollbar.error(e, scope: :progress_report, school_id: @school.id, school: @school.name, fuel_type: @fuel_type)
        @debug_error = e.message
      end
      render :index
    end

    def missing(fuel_type)
      @fuel_type = fuel_type
      render :missing
    end

    def show_storage_heater_notes(school, school_target, fuel_type)
      fuel_type == :electricity && school.has_storage_heaters? && school_target.storage_heaters.present?
    end

    def progress_service
      Targets::ProgressService.new(@school)
    end
  end
end
