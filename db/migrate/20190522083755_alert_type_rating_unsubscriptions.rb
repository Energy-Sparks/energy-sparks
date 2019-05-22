class AlertTypeRatingUnsubscriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :alert_type_rating_unsubscriptions do |t|
      t.references :alert_type_rating, null: false, foreign_key: {on_delete: :cascade}
      t.references :contact, null: false, foreign_key: {on_delete: :cascade}
      t.references :alert_subscription_event, foreign_key: {on_delete: :cascade}, index: {name: 'altunsub_event'}
      t.integer :scope, null: false
      t.text :reason
      t.integer :unsubscription_period, null: false
      t.date :effective_until
      t.timestamps
    end

    add_column :alert_subscription_events, :unsubscription_uuid, :string, index: true, unique: true
  end
end
