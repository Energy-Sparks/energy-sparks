module Teachers
  class SchoolsController < ApplicationController
    include ActivityTypeFilterable

    load_and_authorize_resource
    skip_before_action :authenticate_user!

    def show
      redirect_to enrol_path unless @school.active? || (current_user && current_user.manages_school?(@school.id))
      @charts = [:teachers_landing_page_electricity, :teachers_landing_page_gas]
      setup_find_out_more
      setup_activity_suggestions
    end

  private

    def setup_find_out_more
      @find_out_more_alert = @school.latest_find_out_mores.sample

      if @find_out_more_alert
        @find_out_more_alert_content = TemplateInterpolation.new(
          @find_out_more_alert.content_version,
          proxy: [:colour]
        ).interpolate(
          :teacher_dashboard_title,
          with: @find_out_more_alert.alert.template_variables
        )
        activity_type_filter = ActivityTypeFilter.new(school: @school, scope: @find_out_more_alert.activity_types, query: { not_completed_or_repeatable: true })
        @find_out_more_alert_activity_types = activity_type_filter.activity_types.limit(3)
      end
    end

    def setup_activity_suggestions
      @first = @school.activities.empty?
      @activities_count = @school.activities.count
      @suggestions = NextActivitySuggesterWithFilter.new(@school, activity_type_filter).suggest
    end
  end
end
