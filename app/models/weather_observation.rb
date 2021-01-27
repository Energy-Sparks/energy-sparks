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
#  index_weather_obs_on_weather_station_id                   (weather_station_id)
#  index_weather_obs_on_weather_station_id_and_reading_date  (weather_station_id,reading_date) UNIQUE
#  index_weather_observations_on_weather_station_id          (weather_station_id)
#
# Foreign Keys
#
#  fk_rails_...  (weather_station_id => weather_stations.id)
#
class WeatherObservation < ApplicationRecord
  belongs_to :weather_station
  scope :by_date, -> { order(:reading_date) }
  scope :since, ->(date) { where('reading_date >= ?', date) }
end
