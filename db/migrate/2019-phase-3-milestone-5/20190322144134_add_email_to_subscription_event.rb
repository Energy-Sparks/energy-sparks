class AddEmailToSubscriptionEvent < ActiveRecord::Migration[5.2]
  def change
    add_reference :alert_subscription_events, :email, foreign_key: true
  end
end
