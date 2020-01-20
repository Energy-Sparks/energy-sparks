class CreateSmsRecord < ActiveRecord::Migration[6.0]
  def change
    create_table :sms_records do |t|
      t.references :alert_subscription_event, foreign_key: {on_delete: :cascade}
      t.text :mobile_phone_number
      t.timestamps
    end
  end
end
