module Schools
  class AlertReportsController < ApplicationController
    load_and_authorize_resource :school

    def index
      authorize! :read, AlertType
      @alert_generation_runs = @school.alert_generation_runs.order(created_at: :desc)
    end

    def show
      @run = @school.alert_generation_runs.find(params[:id])
    end
  end
end
