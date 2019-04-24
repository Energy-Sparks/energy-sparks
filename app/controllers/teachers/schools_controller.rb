module Teachers
  class SchoolsController < ApplicationController
    include ActivityTypeFilterable

    load_and_authorize_resource
    skip_before_action :authenticate_user!

    def show
      redirect_to enrol_path unless @school.active? || (current_user && current_user.manages_school?(@school.id))

      # bm = Benchmark.realtime {
      #   # Preload AMR data
      #   cache_key = "#{@school.id}-#{@school.name.parameterize}-amr-validated-meter-collection"
      #   Rails.cache.fetch(cache_key, expires_in: 1.day) do
      #     AmrValidatedMeterCollection.new(@school)
      #   end
      # }

      # Rails.logger.info "€€€€ loaded AmrValidatedMeterCollection for school in #{bm.round(2)} seconds"

      # bm = Benchmark.realtime {
      #   # Preload weather data etc
      #   bath_school = School.where(calendar_area_id: 2).first
      #   sheffield_school = School.where(calendar_area_id: 3).first
      #   frome_school = School.where(calendar_area_id: 6).first
      #   [bath_school, sheffield_school, frome_school].each do |school|
      #     ScheduleDataManagerService.new(school).temperatures
      #     ScheduleDataManagerService.new(school).solar_pv
      #     ScheduleDataManagerService.new(school).solar_irradiation
      #     ScheduleDataManagerService.new(school).co2
      #   end
      # }
      # logger.info "€€€€ Pre-warm holidays etc in #{bm.round(2)} seconds"

      bm = Benchmark.realtime {
        AggregateSchoolService.new(@school).aggregate_school
      }

      logger.info "€€€€ Aggregated school in #{bm.round(2)} seconds"

      @activities_count = @school.activities.count
      @find_out_more_alert = @school.latest_find_out_mores.sample
      if @find_out_more_alert
        @find_out_more_alert_content = TemplateInterpolation.new(
          @find_out_more_alert.content_version,
          proxy: [:colour]
        ).interpolate(
          :teacher_dashboard_title,
          with: @find_out_more_alert.alert.template_variables
        )
        @find_out_more_alert_activity_types = @find_out_more_alert.activity_types.limit(3)
      end

      @charts = [:teachers_landing_page_electricity, :teachers_landing_page_gas]

      @first = @school.activities.empty?
      @completed_activity_count = @school.activities.count
      @suggestions = NextActivitySuggesterWithFilter.new(@school, activity_type_filter).suggest
    end
  end
end
