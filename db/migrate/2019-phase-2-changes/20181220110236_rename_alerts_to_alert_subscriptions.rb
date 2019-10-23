class RenameAlertsToAlertSubscriptions < ActiveRecord::Migration[5.2]
  def change
    rename_table(:alerts, :alert_subscriptions)
  end
end
