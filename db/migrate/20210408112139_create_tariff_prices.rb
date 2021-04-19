class CreateTariffPrices < ActiveRecord::Migration[6.0]
  def change
    create_table :tariff_prices do |t|
      t.references    :meter
      t.references    :tariff_import_log
      t.date          :tariff_date, null: false
      t.json          :prices, default: {}
      t.timestamps
    end
    add_index :tariff_prices, [:meter_id, :tariff_date], unique: true
  end
end
