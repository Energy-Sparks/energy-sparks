class Schools::AlertSubscriptionEventsController < ApplicationController
  load_and_authorize_resource :school
  load_and_authorize_resource through: :school

  def index
    @sent_emails = @school.alert_subscription_events.includes(:email).email.sent.order('emails.sent_at DESC').by_priority
    @pending_emails = @school.alert_subscription_events.includes(:email).email.pending.order(:created_at).by_priority
    @sent_sms = @school.alert_subscription_events.sms.sent
    @pending_sms = @school.alert_subscription_events.sms.pending
  end

  def show
  end
end
