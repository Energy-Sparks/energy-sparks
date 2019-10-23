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

class AmrDataFeedReading < ApplicationRecord
  belongs_to :meter, optional: true
  belongs_to :amr_data_feed_import_log
  belongs_to :amr_data_feed_config

  def self.download_all_data
    <<~QUERY
      SELECT s.urn, s.name, m.mpan_mprn, amr.reading_date, c.date_format, amr.updated_at,  amr.readings
      FROM  amr_data_feed_readings amr, meters m, schools s, amr_data_feed_configs c
      WHERE amr.meter_id = m.id
      AND   m.school_id  = s.id
      AND   amr.amr_data_feed_config_id = c.id
      ORDER BY s.id, m.mpan_mprn ASC
    QUERY
  end
end
