module Schools
  class SubscriptionGenerationRunsController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource through: :school

    layout 'dashboards'

    def index
      @subscription_generation_runs = @subscription_generation_runs.order(created_at: :desc)
    end

    def show
      @sent_emails = @subscription_generation_run.alert_subscription_events.includes(:email).email.sent.order('emails.contact_id').by_priority
      @pending_emails = @subscription_generation_run.alert_subscription_events.includes(:email).email.pending.order(:created_at).by_priority
      @sent_sms = @subscription_generation_run.alert_subscription_events.sms.sent
      @pending_sms = @subscription_generation_run.alert_subscription_events.sms.pending
    end
  end
end
