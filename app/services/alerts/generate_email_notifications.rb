module Alerts
  class GenerateEmailNotifications
    def perform
      AlertSubscriptionEvent.where(status: :pending, communication_type: :email).each do |event|
        AlertMailer.with(email_address: event.contact.email_address, alerts: [event.alert], school: event.alert_subscription.school).alert_email.deliver_now
        event.update(status: :sent)
        # event
      end
    end
  end
end
