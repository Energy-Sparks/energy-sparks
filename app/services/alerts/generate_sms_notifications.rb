module Alerts
  class GenerateSmsNotifications
    def initialize(subscription_generation_run:, send_sms_service: SendSms)
      @send_sms_service = send_sms_service
      @subscription_generation_run = subscription_generation_run
    end

    def perform
      @subscription_generation_run.alert_subscription_events.where(status: :pending, communication_type: :sms).each do |event|
        next if event.content_version.nil?
        sms_content = TemplateInterpolation.new(
          event.content_version,
        ).interpolate(
          :sms_content,
          with: event.alert.template_variables
        ).sms_content
        @send_sms_service.new("EnergySparks alert: " + sms_content, event.contact.mobile_phone_number).send
        event.update(status: :sent)
      end
    end
  end
end
