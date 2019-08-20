module Teachers
  class SchoolsController < ApplicationController
    load_and_authorize_resource

    include SchoolAggregation
    include ActivityTypeFilterable

    skip_before_action :authenticate_user!

    def show
      redirect_to enrol_path unless @school.active? || (current_user && current_user.manages_school?(@school.id))

      setup_charts
      setup_dashboard_alert
      setup_activity_suggestions
      setup_timeline
    end

  private

    def setup_charts
      @charts = {}

      if @school.configuration.electricity
        @charts[:electricity] = :teachers_landing_page_electricity
      end

      if @school.configuration.gas_dashboard_chart_type.to_sym != Schools::Configuration::NO_CHART
        @charts[:gas] = @school.configuration.gas_dashboard_chart_type.to_sym
      end
    end

    def setup_dashboard_alert
      @dashboard_alert = @school.latest_dashboard_alerts.includes(:content_version, :find_out_more).teacher_dashboard.sample

      if @dashboard_alert
        @dashboard_alert_content = TemplateInterpolation.new(
          @dashboard_alert.content_version,
          with_objects: { find_out_more: @dashboard_alert.find_out_more },
          proxy: [:colour]
        ).interpolate(
          :teacher_dashboard_title,
          with: @dashboard_alert.alert.template_variables
        )
      end
    end

    def setup_activity_suggestions
      @activities_count = @school.activities.count
      suggester = NextActivitySuggesterWithFilter.new(@school, activity_type_filter)
      @activities_from_programmes = suggester.suggest_from_programmes.limit(1)
      @activities_from_alerts = suggester.suggest_from_find_out_mores.sample(1)
      if @activities_from_programmes.empty?
        started_programmes = @school.programmes.active
        @suggested_programme = ProgrammeType.active.where.not(id: started_programmes.map(&:programme_type_id)).sample
      end
      cards_filled = [@activities_from_programmes + @activities_from_alerts + [@suggested_programme]].flatten.compact.size
      @activities_from_activity_history = suggester.suggest_from_activity_history.slice(0, (3 - cards_filled))
    end

    def setup_timeline
      @observations = @school.observations.order('at DESC').limit(10)
    end
  end
end
