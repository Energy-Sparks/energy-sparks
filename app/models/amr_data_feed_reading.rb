# == Schema Information
#
# Table name: amr_data_feed_readings
#
#  amr_data_feed_config_id :bigint(8)
#  created_at              :datetime         not null
#  description             :text
#  id                      :bigint(8)        not null, primary key
#  meter_id                :bigint(8)
#  meter_serial_number     :text
#  mpan_mprn               :text             not null
#  postcode                :text
#  provider_record_id      :text
#  reading_date            :text             not null
#  readings                :text             not null, is an Array
#  school                  :text
#  total                   :text
#  type                    :text
#  units                   :text
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_amr_data_feed_readings_on_amr_data_feed_config_id  (amr_data_feed_config_id)
#  index_amr_data_feed_readings_on_meter_id                 (meter_id)
#

class AmrDataFeedReading < ApplicationRecord
  belongs_to :meter, optional: true
end
