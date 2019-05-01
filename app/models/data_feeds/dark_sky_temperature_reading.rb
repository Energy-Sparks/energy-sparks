# == Schema Information
#
# Table name: dark_sky_temperature_readings
#
#  area_id                 :bigint(8)
#  created_at              :datetime         not null
#  id                      :bigint(8)        not null, primary key
#  reading_date            :date             not null
#  temperature_celsius_x48 :decimal(, )      not null, is an Array
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_dark_sky_temperature_readings_on_area_id       (area_id)
#  index_dark_sky_temperature_readings_on_reading_date  (reading_date) UNIQUE
#

module DataFeeds
  class DarkSkyTemperatureReading < ApplicationRecord
  end
end
