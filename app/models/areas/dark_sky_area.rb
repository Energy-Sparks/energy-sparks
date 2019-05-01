# == Schema Information
#
# Table name: areas
#
#  description    :text
#  id             :bigint(8)        not null, primary key
#  latitude       :decimal(10, 6)
#  longitude      :decimal(10, 6)
#  parent_area_id :bigint(8)
#  title          :text
#  type           :text             not null
#
# Indexes
#
#  index_areas_on_parent_area_id  (parent_area_id)
#

module Areas
  class DarkSkyArea < Area
    has_many :dark_sky_temperature_readings, class_name: 'DataFeeds::DarkSkyTemperatureReading', foreign_key: :area_id
  end
end
