class CreateDarkSkyTemperatureReadings < ActiveRecord::Migration[5.2]
  def change
    create_table :dark_sky_temperature_readings do |t|
      t.references    :area
      t.date          :reading_date,              null: false
      t.decimal       :temperature_celsius_x48,   null: false, array: true
      t.timestamps
    end

    add_index :dark_sky_temperature_readings, [:area_id, :reading_date], unique: true
  end
end
