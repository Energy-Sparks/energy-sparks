# == Schema Information
#
# Table name: weather_observations
#
#  created_at              :datetime         not null
#  id                      :bigint(8)        not null, primary key
#  reading_date            :date             not null
#  temperature_celsius_x48 :decimal(, )      not null, is an Array
#  updated_at              :datetime         not null
#  weather_station_id      :bigint(8)        not null
#
# Indexes
#
#  index_weather_obs_on_weather_station_id_and_reading_date  (weather_station_id,reading_date) UNIQUE
#  index_weather_observations_on_weather_station_id          (weather_station_id)
#
# Foreign Keys
#
#  fk_rails_...  (weather_station_id => weather_stations.id) ON DELETE => cascade
#
class WeatherObservation < ApplicationRecord
  belongs_to :weather_station
  scope :by_date, -> { order(:reading_date) }
  scope :since, ->(date) { where('reading_date >= ?', date) }

  def self.download_all_data
    <<~QUERY
      SELECT station.title, obs.reading_date, obs.temperature_celsius_x48
      FROM  weather_observations obs, weather_stations station
      WHERE obs.weather_station_id = station.id
      ORDER BY station.id, obs.reading_date ASC
    QUERY
  end

  def self.download_for_area_id(id)
    <<~QUERY
      SELECT station.title, obs.reading_date, obs.temperature_celsius_x48
      FROM  weather_observations obs, weather_stations station
      WHERE obs.weather_station_id = station.id
      AND   obs.weather_station_id = #{id}
      ORDER BY station.id, obs.reading_date ASC
    QUERY
  end
end
