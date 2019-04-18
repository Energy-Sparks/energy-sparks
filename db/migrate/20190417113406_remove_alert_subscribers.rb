class RemoveAlertSubscribers < ActiveRecord::Migration[5.2]
  def up
    remove_column :alert_subscription_events, :alert_subscription_id
    drop_table :alert_subscriptions
    drop_table :alert_subscriptions_contacts
  end
end
