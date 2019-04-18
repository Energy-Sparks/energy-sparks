module Alerts
  class GenerateSmsNotifications
    def initialize(send_sms_service = SendSms)
      @send_sms_service = send_sms_service
    end

    def perform
      AlertSubscriptionEvent.where(status: :pending, communication_type: :sms).each do |event|
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
