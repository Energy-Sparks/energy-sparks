class ContactForeignKeyFix < ActiveRecord::Migration[6.0]
  def up
    # remove existing without on_delete
    remove_foreign_key :alert_subscription_events, :contacts
    remove_foreign_key :alert_subscription_events, :emails

    add_foreign_key :alert_subscription_events, :contacts, on_delete: :cascade
    add_foreign_key :alert_subscription_events, :emails, on_delete: :nullify
  end

  def down
    remove_foreign_key :alert_subscription_events, :contacts
    remove_foreign_key :alert_subscription_events, :emails

    # create without on_delete
    add_foreign_key :alert_subscription_events, :contacts
    add_foreign_key :alert_subscription_events, :emails
  end
end
