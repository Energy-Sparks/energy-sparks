module Alerts
  class GenerateEmailNotifications
    def perform
      Contact.all.each do |contact|
        events = contact.alert_subscription_events.where(status: :pending, communication_type: :email)
        if events.any?
          alerts = events.map(&:alert)
          alert_ids_as_string_parameter = alerts.pluck(:id).to_s

          AlertMailer.with(email_address: contact.email_address, alert_ids: alert_ids_as_string_parameter, school_id: contact.school.id).alert_email.deliver_now
          events.update_all(status: :sent)
        end
      end
    end
  end
end
