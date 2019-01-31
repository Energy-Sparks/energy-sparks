module Alerts
  class GenerateNotifications
    def perform
      AlertSubscriptionEvent.where(status: pending).each do |event|
        # Send email
        # Send SMS
      end
    end
  end
end
