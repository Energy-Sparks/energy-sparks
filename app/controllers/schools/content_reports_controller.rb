module Schools
  class ContentReportsController < ApplicationController
    include DashboardAlerts
    include DashboardPriorities
    include AnalysisPages
    load_and_authorize_resource :school

    def index
      authorize! :read, ContentGenerationRun
      @content_generation_runs = @school.content_generation_runs.order(created_at: :desc)
    end

    def show
      @run = @school.content_generation_runs.find(params[:id])

      @teacher_dashboard_alerts = setup_alerts(@run.dashboard_alerts.teacher_dashboard, :teacher_dashboard_title, limit: nil)
      @pupil_dashboard_alerts = setup_alerts(@run.dashboard_alerts.pupil_dashboard, :pupil_dashboard_title, limit: nil)
      @public_dashboard_alerts = setup_alerts(@run.dashboard_alerts.public_dashboard, :public_dashboard_title, limit: nil)
      @management_dashboard_alerts = setup_alerts(@run.dashboard_alerts.management_dashboard, :management_dashboard_title, limit: nil)
      @management_priorities = setup_priorities(@run.management_priorities)
      setup_analysis_pages(@run.analysis_pages)
    end
  end
end
