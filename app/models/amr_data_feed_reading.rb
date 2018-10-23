# == Schema Information
#
# Table name: amr_data_feed_readings
#
#  amr_data_feed_config_id :integer          not null
#  created_at              :datetime         not null
#  description             :text
#  id                      :bigint(8)        not null, primary key
#  meter_id                :integer
#  meter_serial_number     :text
#  mpan_mprn               :bigint(8)        not null
#  postcode                :text
#  provider_record_id      :text
#  reading_date            :date             not null
#  readings                :decimal(, )      not null, is an Array
#  school                  :text
#  total                   :decimal(, )
#  type                    :text
#  units                   :text
#  updated_at              :datetime         not null
#
# Indexes
#
#  unique_meter_readings  (mpan_mprn,reading_date) UNIQUE
#
# Foreign Keys
#
#  amr_data_feed_readings_config_id_fk  (amr_data_feed_config_id => amr_data_feed_configs.id)
#

class AmrDataFeedReading < ApplicationRecord
end
