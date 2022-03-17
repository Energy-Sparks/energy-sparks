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

    def summary_table
      if EnergySparks::FeatureFlags.active?(:use_management_data)
        Schools::ManagementTableService.new(@school).management_data
      end
    end

    def index_for(fuel_type)
      @fuel_type = fuel_type
      @current_target = @school.current_target
      authorize! :show, @current_target
      @show_storage_heater_notes = show_storage_heater_notes(@school, @fuel_type)
      begin
        service = TargetsService.new(aggregate_school, @fuel_type)
        @recent_data = service.recent_data?
        @progress = service.progress
        @partial_consumption = partial_consumption_data?(@progress)
        @partial_targets = partial_target_data?(@progress)
        @overview_data = summary_table
        @suggest_estimates = suggest_estimates
        @debug_content = service.analytics_debug_info if current_user.present? && current_user.analytics?
      rescue => e
        Rollbar.error(e, school_id: @school.id, school: @school.name, fuel_type: @fuel_type)
        @debug_error = e.message
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

    def partial_consumption_data?(progress)
      #this could be more sophisticated, relies on ordering of months array reflecting
      #actual starting month of the target reporting period
      first_month = progress.months.first
      progress.monthly_usage_kwh[first_month].nil? || progress.partial_months[first_month]
    end

    def partial_target_data?(progress)
      progress.monthly_targets_kwh.value?(nil)
    end

    def progress_service
      Targets::ProgressService.new(@school)
    end
  end
end
