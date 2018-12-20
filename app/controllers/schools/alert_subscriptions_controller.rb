class Schools::AlertSubscriptionsController < ApplicationController
  load_and_authorize_resource :school
  load_and_authorize_resource through: :school

  def index
    @alert_subscriptions = @alert_subscriptions.eager_load(:alert_type).order('alert_types.fuel_type')
  end

  def edit
  end

  def update
    if @alert_subscription.update(alert_params)
      redirect_to school_alert_subscriptions_path(@school), notice: 'Alert subscription was successfully updated.'
    else
      render :edit
    end
  end

private

  def alert_params
    params.require(:alert_subscription).permit(contact_ids: [])
  end
end
