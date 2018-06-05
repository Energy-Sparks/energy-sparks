class Schools::AlertsController < ApplicationController

  load_and_authorize_resource :alert
  load_and_authorize_resource :school, find_by: :slug

  skip_before_action :authenticate_user!
  before_action :set_school
  before_action set_alert: [:edit, :update]
 
  def index
    @alerts = @school.alerts
  end

  def edit
    @alert = Alert.find(params[:id])
  end

  def update
    if @alert.update(alert_params)
       redirect_to school_alerts_path(@school), notice: 'Alert was successfully updated.'
    else
       render :edit
    end
  end

private

  def set_alert
    @alert = Alert.find(params[:id])
  end

  def set_school
    @school = School.find(params[:school_id])
  end

  def alert_params
    params.require(:alert).permit(contact_ids: [])
  end
end
