class AddPriorityToAlertContent < ActiveRecord::Migration[6.0]
  def change
    add_column :dashboard_alerts, :priority, :float, default: 0, null: false
    add_column :management_priorities, :priority, :float, default: 0, null: false
    add_column :alert_subscription_events, :priority, :float, default: 0, null: false
  end
end
