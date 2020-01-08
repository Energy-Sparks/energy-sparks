module Schools
  class AlertReportsController < ApplicationController
    load_and_authorize_resource :school

    def index
      authorize! :read, AlertType
      @alert_generation_runs = @school.alert_generation_runs.order(created_at: :desc)
    end

    def show
      @run = @school.alert_generation_runs.find(params[:id])
      @analytics_alerts = @run.alerts.analytics.by_type
      @system_alerts = @run.alerts.system.by_type
      @analysis_alerts = @run.alerts.analysis.by_type
      @errors = @run.alert_errors
    end
  end
end
