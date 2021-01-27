# == Schema Information
#
# Table name: weather_stations
#
#  active      :boolean          default(TRUE)
#  created_at  :datetime         not null
#  description :text
#  id          :bigint(8)        not null, primary key
#  latitude    :decimal(10, 6)
#  longitude   :decimal(10, 6)
#  title       :text
#  provider    :string           not null
#  updated_at  :datetime         not null
#
class WeatherStation < ApplicationRecord
  METEOSTAT = "meteostat".freeze
  has_many :weather_observations, dependent: :destroy
  validates_presence_of :latitude, :longitude, :title, :provider
  validates :provider, inclusion: { in: [METEOSTAT] }
  scope :by_title, -> { order(title: :asc) }
  scope :active_by_provider, ->(provider) { where(active: true, provider: provider) }
  scope :by_provider, ->(provider) { where(provider: provider) }

  def observation_count
    weather_observations.count
  end

  def first_observation_date
    if observation_count > 0
      weather_observations.by_date.first.reading_date.strftime('%d %b %Y')
    end
  end

  def last_observation_date
    if observation_count > 0
      weather_observations.by_date.last.reading_date.strftime('%d %b %Y')
    end
  end
end
