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
#  type        :string           not null
#  updated_at  :datetime         not null
#
class WeatherStation < ApplicationRecord
  has_many :weather_observations, dependent: :destroy

  validates_presence_of :latitude, :longitude, :title, :type

  scope :by_title, -> { order(title: :asc) }
end
