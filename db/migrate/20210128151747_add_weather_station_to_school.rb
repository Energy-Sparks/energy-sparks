class AddWeatherStationToSchool < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :weather_station_id, :bigint, index: true
    add_column :school_onboardings, :weather_station_id, :bigint, index: true
    add_column :school_groups, :default_weather_station_id, :bigint, index: true
  end
end
