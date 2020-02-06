module Alerts
  class GenerateSmsNotifications
    def initialize(subscription_generation_run:, send_sms_service: SendSms)
      @send_sms_service = send_sms_service
      @subscription_generation_run = subscription_generation_run
    end

    def perform
      @subscription_generation_run.alert_subscription_events.where(status: :pending, communication_type: :sms).each do |event|
        next if event.content_version.nil?
        @send_sms_service.new("EnergySparks alert: " + event.sms_content, event.contact.mobile_phone_number).send
        SmsRecord.create!(mobile_phone_number: event.contact.mobile_phone_number, alert_subscription_event: event)
        event.update(status: :sent)
      end
    end
  end
end
