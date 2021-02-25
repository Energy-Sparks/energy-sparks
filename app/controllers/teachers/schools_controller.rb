module Teachers
  class SchoolsController < ApplicationController
    load_and_authorize_resource

    include SchoolAggregation
    include ActivityTypeFilterable
    include DashboardEnergyCharts
    include DashboardAlerts
    include DashboardTimeline
    include AnalysisPages

    before_action :check_aggregated_school_in_cache

    def show
      authorize! :show_teachers_dash, @school
      @charts = setup_charts(@school.configuration)
      @dashboard_alerts = setup_alerts(@school.latest_dashboard_alerts.teacher_dashboard, :teacher_dashboard_title)
      @observations = setup_timeline(@school.observations)

      setup_activity_suggestions
      setup_analysis_pages(@school.latest_analysis_pages)
    end

  private

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
  end
end
