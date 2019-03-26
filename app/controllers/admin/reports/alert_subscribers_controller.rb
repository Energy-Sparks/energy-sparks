module Admin::Reports
  class AlertSubscribersController < AdminController
    def index
      @contacts = Contact.includes(:school, :alert_subscriptions).all.order(:school_id)
    end
  end
end
