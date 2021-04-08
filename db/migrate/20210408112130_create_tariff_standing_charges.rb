class CreateTariffStandingCharges < ActiveRecord::Migration[6.0]
  def change
    create_table :tariff_standing_charges do |t|
      t.references    :meter
      t.references    :tariff_import_log
      t.date          :start_date, null: false
      t.decimal       :value, null: false
      t.timestamps
    end
    add_index :tariff_standing_charges, [:meter_id, :start_date], unique: true
  end
end


