class Schools::AlertsController < ApplicationController
  load_and_authorize_resource :school

  def index
    authorize! :read, AlertType

    @gas_alerts = @school.alerts.gas.latest.sort_by { |a| a.data['rating'] }
    @electricity_alerts = @school.alerts.electricity.latest.sort_by { |a| a.data['rating'] }
  end

  def show
    @alert = Alert.find(params[:id])
  end
end
