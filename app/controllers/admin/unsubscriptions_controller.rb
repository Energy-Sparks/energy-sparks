module Admin
  class UnsubscriptionsController < AdminController
    def index
      @email_unsubscriptions = AlertTypeRatingUnsubscription.email.order(
        created_at: :desc
      ).includes(
        :alert_type_rating, contact: :school, alert_subscription_event: { alert: :alert_type }
      )
    end
  end
end
