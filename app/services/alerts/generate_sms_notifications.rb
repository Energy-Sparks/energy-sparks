module Alerts
  class GenerateSmsNotifications
    def perform
      AlertSubscriptionEvent.where(status: pending, communication_type: :sms).each do |event|
        # Send SMS
      end
    end
  end
end
