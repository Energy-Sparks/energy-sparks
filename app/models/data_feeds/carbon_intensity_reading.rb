# == Schema Information
#
# Table name: carbon_intensity_readings
#
#  carbon_intensity_x48 :decimal(, )      not null, is an Array
#  created_at           :datetime         not null
#  id                   :bigint(8)        not null, primary key
#  reading_date         :date             not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_carbon_intensity_readings_on_reading_date  (reading_date) UNIQUE
#

module DataFeeds
  class CarbonIntensityReading < ApplicationRecord
    def self.download_all_data
      <<~QUERY
        SELECT reading_date, carbon_intensity_x48
        FROM  carbon_intensity_readings
        ORDER BY reading_date ASC
      QUERY
    end
  end
end
