module Teachers
  class SchoolsController < ApplicationController
    include ActivityTypeFilterable

    load_and_authorize_resource
    skip_before_action :authenticate_user!

    def show
      redirect_to enrol_path unless @school.active? || (current_user && current_user.manages_school?(@school.id))

      if AggregateSchoolService.new(@school).in_cache_or_cache_off?
        @charts = [:teachers_landing_page_electricity, :teachers_landing_page_gas]
        setup_dashboard_alert
        setup_activity_suggestions
      else
        session[:aggregated_meter_collection_referrer] = request.original_fullpath
        redirect_to school_aggregated_meter_collection_path(@school)
      end
    end

  private

    def setup_dashboard_alert
      @dashboard_alert = @school.latest_dashboard_alerts.teacher.sample

      if @dashboard_alert
        @dashboard_alert_content = TemplateInterpolation.new(
          @dashboard_alert.content_version,
          with_objects: { find_out_more: @dashboard_alert.find_out_more },
          proxy: [:colour]
        ).interpolate(
          :teacher_dashboard_title,
          with: @dashboard_alert.alert.template_variables
        )
        if @dashboard_alert_content.find_out_more
          activity_type_filter = ActivityTypeFilter.new(school: @school, scope: @dashboard_alert_content.find_out_more.activity_types, query: { not_completed_or_repeatable: true })
          @find_out_more_activity_types = activity_type_filter.activity_types.limit(3)
        end
      end
    end

    def setup_activity_suggestions
      @first = @school.activities.empty?
      @activities_count = @school.activities.count
      @suggestions = NextActivitySuggesterWithFilter.new(@school, activity_type_filter).suggest
    end
  end
end
