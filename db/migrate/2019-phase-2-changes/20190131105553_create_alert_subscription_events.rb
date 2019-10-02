class CreateAlertSubscriptionEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :alert_subscription_events do |t|
      t.references  :alert_subscription,  foreign_key: true
      t.references  :alert,               foreign_key: true
      t.references  :contact,             foreign_key: true
      t.integer     :status,             null: false, default: 0
      t.integer     :communication_type, null: false, default: 0
      t.text        :message
      t.timestamps
    end
  end
end
