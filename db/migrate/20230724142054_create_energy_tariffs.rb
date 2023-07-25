class CreateEnergyTariffs < ActiveRecord::Migration[6.0]
  def change
    create_table :energy_tariffs do |t|
      t.references    :tariff_holder, polymorphic: true, null: true, index: true
      t.integer       :source, null: false, default: 0
      t.integer       :meter_type, null: false, default: 0
      t.integer       :tariff_type, null: false, default: 0
      t.text          :name, null: false
      t.date          :start_date, null: true
      t.date          :end_date, null: true
      t.boolean       :enabled, default: false
      t.boolean       :ccl, default: false
      t.boolean       :tnuos, default: false
      t.integer       :vat_rate, null: true
      t.references    :created_by, foreign_key: { to_table: 'users' }, null: true
      t.references    :updated_by, foreign_key: { to_table: 'users' }, null: true
      t.timestamps
    end
    create_table :energy_tariff_prices do |t|
      t.references    :energy_tariff, null: false, index: true
      t.time          :start_time, null: false, default: '00:00:00'
      t.time          :end_time, null: false, default: '23:30:00'
      t.decimal       :value, null: false, default: 0
      t.text          :units, null: true
      t.text          :description, null: true
      t.timestamps
    end
    create_table :energy_tariff_charges do |t|
      t.references    :energy_tariff, null: false, index: true
      t.text          :charge_type, null: false
      t.decimal       :value, null: false
      t.text          :units, null: true
      t.timestamps
    end
    create_table :meters_energy_tariffs, id: false do |t|
      t.belongs_to :meter
      t.belongs_to :energy_tariff
    end
  end
end
