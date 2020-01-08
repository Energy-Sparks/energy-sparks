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

# TUOS is The University of Sheffield
class SolarPvTuosArea < Area
  has_many :solar_pv_tuos_readings, class_name: 'DataFeeds::SolarPvTuosReading', foreign_key: :area_id

  validates_presence_of :latitude, :longitude, :title
end
