# == Schema Information
#
# Table name: areas
#
#  description :text
#  id          :bigint(8)        not null, primary key
#  latitude    :decimal(10, 6)
#  longitude   :decimal(10, 6)
#  title       :text
#  type        :text             not null
#

class DarkSkyArea < Area
  has_many :dark_sky_temperature_readings, class_name: 'DataFeeds::DarkSkyTemperatureReading', foreign_key: :area_id

  validates_presence_of :latitude, :longitude, :title
end
