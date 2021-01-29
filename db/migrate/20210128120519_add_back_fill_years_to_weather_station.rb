class AddBackFillYearsToWeatherStation < ActiveRecord::Migration[6.0]
  def change
    add_column :weather_stations, :back_fill_years, :integer, default: 4
  end
end
