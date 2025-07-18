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
#  index_amr_validated_readings_on_meter_id_and_one_day_kwh  (meter_id,one_day_kwh)
#  index_amr_validated_readings_on_reading_date              (reading_date)
#  unique_amr_meter_validated_readings                       (meter_id,reading_date) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (meter_id => meters.id) ON DELETE => cascade
#

# Postgres autovacuum specific settings:
# See: https://www.postgresql.org/docs/current/runtime-config-autovacuum.html
# Applied using: ALTER TABLE amr_validated_readings SET (X = n)
# autovacuum_vacuum_cost_delay = 0
# autovacuum_analyze_scale_factor = 0
# autovacuum_analyze_threshold = 10000
# autovacuum_vacuum_scale_factor = 0
# autovacuum_vacuum_threshold = 50000
class AmrValidatedReading < ApplicationRecord
  belongs_to :meter, inverse_of: :amr_validated_readings

  scope :original, -> { where(status: 'ORIG') }
  scope :modified, -> { where.not(status: 'ORIG') }
  scope :by_date, -> { order(reading_date: :asc) }
  scope :since, ->(date) { where('reading_date >= ?', date) }
  scope :with_status, ->(status) { where(status: status) }

  CSV_HEADER_FOR_SCHOOL = 'Mpan Mprn,Meter Type,Reading Date,One Day Total kWh,Status,Substitute Date,00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30,00:00'.freeze

  def modified
    status != 'ORIG'
  end

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

  def self.download_query_for_meter(meter)
    <<~QUERY
      SELECT m.mpan_mprn,
             CASE m.meter_type WHEN 0 THEN 'Electricity' WHEN 1 THEN 'Gas' WHEN 2 THEN 'Solar PV' WHEN 3 THEN 'Exported Solar PV' END,
             reading_date,
             one_day_kwh,
             status,
             substitute_date,
             kwh_data_x48
      FROM amr_validated_readings amr, meters m
      WHERE amr.meter_id = m.id
      AND amr.meter_id = #{meter.id}
      ORDER BY reading_date ASC
    QUERY
  end

  def self.download_query_for_school(school)
    <<~QUERY
      SELECT m.mpan_mprn,
             CASE m.meter_type WHEN 0 THEN 'Electricity' WHEN 1 THEN 'Gas' WHEN 2 THEN 'Solar PV' WHEN 3 THEN 'Exported Solar PV' END,
             amr.reading_date,
             amr.one_day_kwh,
             amr.status,
             amr.substitute_date,
             amr.kwh_data_x48
      FROM  amr_validated_readings amr, meters m
      WHERE amr.meter_id = m.id
      AND   m.school_id = #{school.id}
      ORDER BY m.mpan_mprn, amr.reading_date ASC
    QUERY
  end
end
