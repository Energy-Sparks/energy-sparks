class CreateSolarPvReadingsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :solar_pv_tuos_readings do |t|
      t.references    :area,                null: false, foreign_key: { on_delete: :cascade }
      t.text          :gsp_name
      t.integer       :gsp_id
      t.decimal       :latitude
      t.decimal       :longitude
      t.decimal       :distance_km
      t.date          :reading_date,        null: false
      t.decimal       :generation_mw_x48,   null: false, array: true
      t.timestamps
    end

    add_index :solar_pv_tuos_readings, [:area_id, :reading_date], unique: true
  end
end
