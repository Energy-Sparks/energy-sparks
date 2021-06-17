class CreateUserTariffs < ActiveRecord::Migration[6.0]
  def change
    create_table :user_tariffs do |t|
      t.references    :school, null: false
      t.text          :name, null: false
      t.text          :fuel_type, null: false
      t.boolean       :flat_rate, default: true
      t.date          :start_date, null: false
      t.date          :end_date, null: false
      t.timestamps
    end
    create_table :user_tariff_prices do |t|
      t.references    :user_tariff, null: false
      t.text          :start_time, null: false
      t.text          :end_time, null: false
      t.decimal       :value, null: false
      t.text          :units, null: false
      t.timestamps
    end
    create_table :user_tariff_charges do |t|
      t.references    :user_tariff, null: false
      t.text          :charge_type, null: false
      t.decimal       :value, null: false
      t.text          :units, null: false
      t.timestamps
    end
  end
end
