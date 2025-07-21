module Schools
  class ContentReportsController < ApplicationController
    include DashboardAlerts
    load_and_authorize_resource :school

    layout Flipper.enabled?(:new_manage_school_pages) ? 'dashboards' : 'application'

    def index
      authorize! :view_content_reports, @school
      @content_generation_runs = @school.content_generation_runs.order(created_at: :desc)
    end

    def show
      authorize! :view_content_reports, @school
      @run = @school.content_generation_runs.find(params[:id])
      @pupil_dashboard_alerts = setup_alerts(@run.dashboard_alerts.pupil_dashboard, :pupil_dashboard_title, limit: nil)
      @management_dashboard_alerts = setup_alerts(@run.dashboard_alerts.management_dashboard, :management_dashboard_title, limit: nil)
      @management_priorities = Schools::Priorities.interpolate(@run.management_priorities)
    end
  end
end
