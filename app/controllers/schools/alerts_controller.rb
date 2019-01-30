class Schools::AlertsController < ApplicationController
  load_and_authorize_resource :school

  def index
    authorize! :read, AlertType

    @termly_alerts = @school.alerts.termly.latest
    @weekly_alerts = @school.alerts.weekly.latest
  end

  def show
    @alert = Alert.find(params[:id])
  end
end
