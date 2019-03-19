class Schools::AlertSubscriptionEventsController < ApplicationController
  load_and_authorize_resource :school
  load_and_authorize_resource through: :school

  def index
    @alert_subscription_events = @school.alert_subscription_events
  end
end
