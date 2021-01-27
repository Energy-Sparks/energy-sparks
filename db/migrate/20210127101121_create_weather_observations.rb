class CreateWeatherObservations < ActiveRecord::Migration[6.0]
  def change
    create_table :weather_observations do |t|
      t.references :weather_station, null: false, foreign_key: {on_delete: :cascade}
      t.date :reading_date, null: false
      t.decimal "temperature_celsius_x48", null: false, array: true
      t.timestamps

      t.index ["weather_station_id", "reading_date"], name: "index_weather_obs_on_weather_station_id_and_reading_date", unique: true
    end
  end
end
