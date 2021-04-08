class CreateN3rgyTariffStandingCharges < ActiveRecord::Migration[6.0]
  def change
    create_table :n3rgy_tariff_standing_charges do |t|
      t.references    :meter
      t.references    :n3rgy_tariff_import_log, index: { name: :idx_n3rgy_tariff_standing_charges_import_log_id }
      t.date          :start_date, null: false
      t.decimal       :value, null: false
      t.timestamps
    end
    add_index :n3rgy_tariff_standing_charges, [:meter_id, :start_date], unique: true
  end
end


