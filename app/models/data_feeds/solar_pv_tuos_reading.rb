# == Schema Information
#
# Table name: solar_pv_tuos_readings
#
#  area_id           :bigint(8)        not null
#  created_at        :datetime         not null
#  distance_km       :decimal(, )
#  generation_mw_x48 :decimal(, )      not null, is an Array
#  gsp_id            :integer
#  gsp_name          :text
#  id                :bigint(8)        not null, primary key
#  latitude          :decimal(, )
#  longitude         :decimal(, )
#  reading_date      :date             not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_solar_pv_tuos_readings_on_area_id                   (area_id)
#  index_solar_pv_tuos_readings_on_area_id_and_reading_date  (area_id,reading_date) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (area_id => areas.id) ON DELETE => cascade
#
module DataFeeds
  class SolarPvTuosReading < ApplicationRecord
    belongs_to :solar_pv_tuos_area, foreign_key: :area_id

    scope :by_date, -> { order(:reading_date) }
    scope :since, ->(date) { where('reading_date >= ?', date) }

    def self.download_all_data
      <<~QUERY
        SELECT a.title, sptr.reading_date, sptr.generation_mw_x48, sptr.gsp_name, sptr.gsp_id, sptr.latitude, sptr.longitude, sptr.distance_km
        FROM  solar_pv_tuos_readings sptr, areas a
        WHERE sptr.area_id = a.id
        ORDER BY a.id, sptr.reading_date ASC
      QUERY
    end

    def self.download_for_area_id(area_id)
      <<~QUERY
        SELECT a.title, sptr.reading_date, sptr.generation_mw_x48, sptr.gsp_name, sptr.gsp_id, sptr.latitude, sptr.longitude, sptr.distance_km
        FROM  solar_pv_tuos_readings sptr, areas a
        WHERE sptr.area_id = a.id
        AND   sptr.area_id = #{area_id}
        ORDER BY a.id, sptr.reading_date ASC
      QUERY
    end
  end
end
