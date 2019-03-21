class AddMessageIdentifier < ActiveRecord::Migration[5.2]
  def change
    add_column :alert_subscription_events, :message_id, :uuid, null: true
  end
end
