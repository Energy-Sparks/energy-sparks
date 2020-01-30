# == Schema Information
#
# Table name: amr_validated_readings
#
#  id              :bigint(8)        not null, primary key
#  kwh_data_x48    :decimal(, )      not null, is an Array
#  meter_id        :bigint(8)        not null
#  one_day_kwh     :decimal(, )      not null
#  reading_date    :date             not null
#  status          :text             not null
#  substitute_date :date
#  upload_datetime :datetime
#
# Indexes
#
#  index_amr_validated_readings_on_meter_id      (meter_id)
#  index_amr_validated_readings_on_reading_date  (reading_date)
#  unique_amr_meter_validated_readings           (meter_id,reading_date) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (meter_id => meters.id)
#

class AmrValidatedReading < ApplicationRecord
  belongs_to :meter, inverse_of: :amr_validated_readings

  def self.download_all_data
    <<~QUERY
      SELECT s.urn,
             s.name,
             s.postcode,
             CASE m.meter_type WHEN 0 THEN 'Electricity' WHEN 1 THEN 'Gas' WHEN 2 THEN 'Solar PV' WHEN 3 THEN 'Exported Solar PV' END,
             m.mpan_mprn,
             amr.reading_date,
             amr.one_day_kwh,
             amr.status,
             amr.substitute_date,
             amr.kwh_data_x48
      FROM  amr_validated_readings amr, meters m, schools s
      WHERE amr.meter_id = m.id
      AND   m.school_id  = s.id
      ORDER BY s.id, m.mpan_mprn, amr.reading_date ASC
    QUERY
  end

  def self.download_query_for_meter(meter_id)
    <<~QUERY
      SELECT reading_date, one_day_kwh, status, substitute_date, kwh_data_x48
      FROM amr_validated_readings
      WHERE meter_id = #{meter_id}
      ORDER BY reading_date ASC
    QUERY
  end

  def self.download_query_for_school(school)
    meter_ids = school.meters.pluck(:id).join(',')
    <<~QUERY
      SELECT m.mpan_mprn, amr.reading_date, amr.one_day_kwh, amr.status, amr.substitute_date, amr.kwh_data_x48
      FROM  amr_validated_readings amr, meters m
      WHERE amr.meter_id in (#{meter_ids})
      AND   amr.meter_id = m.id
      ORDER BY m.mpan_mprn, amr.reading_date ASC
    QUERY
  end
end
