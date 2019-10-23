class RenameAlertContacts < ActiveRecord::Migration[5.2]
  def change
    rename_table(:alerts_contacts, :alert_subscriptions_contacts)
    rename_column(:alert_subscriptions_contacts, :alert_id, :alert_subscription_id)
  end
end
