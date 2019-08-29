# == Schema Information
#
# Table name: amr_single_readings
#
#  amr_data_feed_config_id     :bigint(8)
#  amr_data_feed_import_log_id :bigint(8)
#  created_at                  :datetime         not null
#  id                          :bigint(8)        not null, primary key
#  meter_id                    :bigint(8)
#  mpan_mprn                   :text             not null
#  reading                     :text             not null
#  reading_date_time           :datetime         not null
#  reading_date_time_as_text   :text             not null
#  reading_type                :integer          not null
#  updated_at                  :datetime         not null
#
# Indexes
#
#  index_amr_single_readings_on_amr_data_feed_config_id      (amr_data_feed_config_id)
#  index_amr_single_readings_on_amr_data_feed_import_log_id  (amr_data_feed_import_log_id)
#  index_amr_single_readings_on_meter_id                     (meter_id)
#

class AmrSingleReading < ApplicationRecord
end
