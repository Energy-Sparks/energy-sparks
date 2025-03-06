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
  scope :between, ->(start_date, end_date) { where(reading_date: start_date..end_date) }
  scope :any_zero_readings, -> { where('0.0 = ANY(temperature_celsius_x48)') }

  CSV_HEADER = 'Area Title,Reading Date,00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30,00:00'.freeze

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
