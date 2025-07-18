# == Schema Information
#
# Table name: weather_stations
#
#  active          :boolean          default(TRUE)
#  back_fill_years :integer          default(4)
#  created_at      :datetime         not null
#  description     :text
#  id              :bigint(8)        not null, primary key
#  latitude        :decimal(10, 6)
#  longitude       :decimal(10, 6)
#  provider        :string           not null
#  title           :text
#  updated_at      :datetime         not null
#
class WeatherStation < ApplicationRecord
  METEOSTAT = 'meteostat'.freeze
  has_many :weather_observations, dependent: :destroy
  validates_presence_of :latitude, :longitude, :title, :provider, :back_fill_years
  validates :provider, inclusion: { in: [METEOSTAT] }
  scope :by_title, -> { order(title: :asc) }
  scope :active_by_provider, ->(provider) { where(active: true, provider: provider) }
  scope :by_provider, ->(provider) { where(provider: provider) }

  def observation_count
    weather_observations.count
  end

  def earliest_observation_date
    weather_observations.by_date&.first&.reading_date
  end

  def latest_observation_date
    weather_observations.by_date&.last&.reading_date
  end

  def has_sufficient_readings?(latest_date, minimum_readings_per_year)
    weather_observations.since(latest_date - back_fill_years.years).count >= minimum_readings_per_year * back_fill_years
  end
end
