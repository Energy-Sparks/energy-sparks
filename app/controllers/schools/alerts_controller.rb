class Schools::AlertsController < ApplicationController
  load_and_authorize_resource :school
  load_and_authorize_resource through: :school

  def index
    @alerts = @alerts.eager_load(:alert_type).order('alert_types.fuel_type')
  end

  def edit
  end

  def update
    if @alert.update(alert_params)
      redirect_to school_alerts_path(@school), notice: 'Alert was successfully updated.'
    else
      render :edit
    end
  end

private

  def alert_params
    params.require(:alert).permit(contact_ids: [])
  end
end
