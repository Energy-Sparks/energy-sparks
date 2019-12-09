# == Schema Information
#
# Table name: amr_data_feed_import_logs
#
#  amr_data_feed_config_id :bigint(8)        not null
#  created_at              :datetime         not null
#  file_name               :text
#  id                      :bigint(8)        not null, primary key
#  import_time             :datetime
#  records_imported        :integer
#  records_upserted        :integer          default(0), not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_amr_data_feed_import_logs_on_amr_data_feed_config_id  (amr_data_feed_config_id)
#

class AmrDataFeedImportLog < ApplicationRecord
  has_many :amr_data_feed_readings
  belongs_to :amr_data_feed_config
end
