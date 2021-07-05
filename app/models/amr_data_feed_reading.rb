# == Schema Information
#
# Table name: amr_data_feed_readings
#
#  amr_data_feed_config_id     :bigint(8)        not null
#  amr_data_feed_import_log_id :bigint(8)        not null
#  created_at                  :datetime         not null
#  description                 :text
#  id                          :bigint(8)        not null, primary key
#  meter_id                    :bigint(8)
#  meter_serial_number         :text
#  mpan_mprn                   :text             not null
#  postcode                    :text
#  provider_record_id          :text
#  reading_date                :text             not null
#  readings                    :text             not null, is an Array
#  school                      :text
#  total                       :text
#  type                        :text
#  units                       :text
#  updated_at                  :datetime         not null
#
# Indexes
#
#  index_amr_data_feed_readings_on_amr_data_feed_config_id      (amr_data_feed_config_id)
#  index_amr_data_feed_readings_on_amr_data_feed_import_log_id  (amr_data_feed_import_log_id)
#  index_amr_data_feed_readings_on_meter_id                     (meter_id)
#  index_amr_data_feed_readings_on_mpan_mprn                    (mpan_mprn)
#  unique_meter_readings                                        (mpan_mprn,reading_date) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (amr_data_feed_config_id => amr_data_feed_configs.id) ON DELETE => cascade
#  fk_rails_...  (amr_data_feed_import_log_id => amr_data_feed_import_logs.id) ON DELETE => cascade
#  fk_rails_...  (meter_id => meters.id) ON DELETE => nullify
#

class AmrDataFeedReading < ApplicationRecord
  belongs_to :meter, optional: true
  belongs_to :amr_data_feed_import_log
  belongs_to :amr_data_feed_config

  CSV_HEADER_DATA_FEED_READING = "School URN,Name,Mpan Mprn,Meter Type,Reading Date,Reading Date Format,Record Last Updated,00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30,00:00".freeze

  def self.download_all_data
    <<~QUERY
      SELECT s.urn,
             s.name,
             m.mpan_mprn,
             CASE m.meter_type WHEN 0 THEN 'Electricity' WHEN 1 THEN 'Gas' WHEN 2 THEN 'Solar PV' WHEN 3 THEN 'Exported Solar PV' END,
             amr.reading_date,
             c.date_format,
             amr.updated_at,
             amr.readings
      FROM  amr_data_feed_readings amr, meters m, schools s, amr_data_feed_configs c
      WHERE amr.meter_id = m.id
      AND   m.school_id  = s.id
      AND   amr.amr_data_feed_config_id = c.id
      ORDER BY s.id, m.mpan_mprn ASC
    QUERY
  end

  def self.download_query_for_school(school_id)
    <<~QUERY
      SELECT s.urn,
             s.name,
             m.mpan_mprn,
             CASE m.meter_type WHEN 0 THEN 'Electricity' WHEN 1 THEN 'Gas' WHEN 2 THEN 'Solar PV' WHEN 3 THEN 'Exported Solar PV' END,
             amr.reading_date,
             c.date_format,
             amr.updated_at,
             amr.readings
      FROM  amr_data_feed_readings amr, meters m, schools s, amr_data_feed_configs c
      WHERE amr.meter_id = m.id
      AND   m.school_id  = s.id
      AND   s.id         = #{school_id}
      AND   amr.amr_data_feed_config_id = c.id
      ORDER BY s.id, m.mpan_mprn ASC
    QUERY
  end
end
