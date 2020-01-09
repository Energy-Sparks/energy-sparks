class RemoveWeatherUndergroundReference < ActiveRecord::Migration[6.0]
  def change
    remove_column :schools, :weather_underground_area_id, :integer
    remove_column :school_groups, :default_weather_underground_area_id, :integer
    remove_column :school_onboardings, :weather_underground_area_id, :integer
  end
end
