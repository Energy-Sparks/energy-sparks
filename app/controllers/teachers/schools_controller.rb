module Teachers
  class SchoolsController < ApplicationController
    load_and_authorize_resource

    include SchoolAggregation
    include ActivityTypeFilterable

    skip_before_action :authenticate_user!

    def show
      redirect_to enrol_path unless @school.active? || (current_user && current_user.manages_school?(@school.id))

      @charts = {}

      if @school.meters_for_supply(:electricity).any?
        @charts[:electricity] = :teachers_landing_page_electricity
      end

      if @school.configuration.gas_dashboard_chart_type.to_sym != :no_chart
        @charts[:gas] = @school.configuration.gas_dashboard_chart_type.to_sym
      end

      setup_dashboard_alert
      setup_activity_suggestions
    end

  private

    def setup_dashboard_alert
      @dashboard_alert = @school.latest_dashboard_alerts.includes(:content_version, :find_out_more).teacher.sample

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
