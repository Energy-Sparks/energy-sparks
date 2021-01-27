class CreateWeatherStations < ActiveRecord::Migration[6.0]
  def change
    create_table :weather_stations do |t|
      t.text :title
      t.text :description
      t.string :type, null: false
      t.boolean :active, default: true
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6

      t.timestamps
    end
  end
end
