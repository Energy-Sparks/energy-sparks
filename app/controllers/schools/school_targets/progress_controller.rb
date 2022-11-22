module Schools
  module SchoolTargets
    class ProgressController < ApplicationController
      load_and_authorize_resource :school
      load_and_authorize_resource :school_target, through: :school

      include SchoolAggregation
      include SchoolProgress

      before_action :redirect_if_disabled
      before_action :check_aggregated_school_in_cache

      skip_before_action :authenticate_user!

      def electricity
        #find school target, redirect
        progress_service.display_progress_for_fuel_type?(:electricity) ? index_for(:electricity) : missing(:electricity)
      end

      def gas
        #find school target, redirect
        progress_service.display_progress_for_fuel_type?(:gas) ? index_for(:gas) : missing(:gas)
      end

      def storage_heater
        #find school target, redirect
        progress_service.display_progress_for_fuel_type?(:storage_heaters) ? index_for(:storage_heater) : missing(:storage_heater)
      end

      private

      #extract into helper?
      def index_for(fuel_type)
        @fuel_type = fuel_type
        authorize! :show, @school_target
        @show_storage_heater_notes = show_storage_heater_notes(@school, @school_target, @fuel_type)

        if @school_target.current?
          service = TargetsService.new(aggregate_school, @fuel_type)
          begin
            @recent_data = service.recent_data?
            @progress = service.progress
            @this_month_target = @progress.cumulative_targets_kwh[this_month]
            #the analytics can return a report with >12 months
            #but we only want to report on a year at a time
            @reporting_months = @progress.months[0..11]
            @suggest_estimate_important = suggest_estimate_for_fuel_type?(@fuel_type, check_data: true)
            @debug_content = service.analytics_debug_info if current_user.present? && current_user.analytics?
          rescue => e
            Rails.logger.error e
            Rails.logger.error e.backtrace.join("\n")
            Rollbar.error(e, scope: :progress_report, school_id: @school.id, school: @school.name, fuel_type: @fuel_type)
            @debug_error = e.message
            begin
              @debug_problem = TargetsService.new(aggregate_school, @fuel_type).target_meter_calculation_problem
              @bad_estimate = bad_estimate?(@debug_problem[:type])
            rescue => ex
              Rails.logger.error ex
              Rollbar.error(ex, scope: :target_meter_calculation_problem, school_id: @school.id, school: @school.name, fuel_type: @fuel_type)
            end
          end
          render :current
        else
          @progress = @school_target.saved_progress_report_for(@fuel_type)
          @this_month_target = @progress.cumulative_targets_kwh[this_month]

          #the analytics can return a report with >12 months
          #but we only want to report on a year at a time
          @reporting_months = @progress.months[0..11]
          render :expired
        end
      end

      def this_month
        #if target is expired, then use the final month, otherwise report on
        #current progress
        if @school_target.expired?
          @school_target.target_date.prev_month.beginning_of_month
        else
          Time.zone.today.beginning_of_month
        end
      end

      def bad_estimate?(type)
        [MissingGasEstimationBase::MoreDataAlreadyThanEstimate, MissingElectricityEstimation::MoreDataAlreadyThanEstimate].include?(type)
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
end
