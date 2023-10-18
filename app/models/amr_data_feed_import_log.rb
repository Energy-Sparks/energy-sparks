# == Schema Information
#
# Table name: amr_data_feed_import_logs
#
#  amr_data_feed_config_id :bigint(8)        not null
#  created_at              :datetime         not null
#  error_messages          :text
#  file_name               :text
#  id                      :bigint(8)        not null, primary key
#  import_time             :datetime
#  records_imported        :integer
#  records_updated         :integer          default(0), not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_amr_data_feed_import_logs_on_amr_data_feed_config_id  (amr_data_feed_config_id)
#

class AmrDataFeedImportLog < ApplicationRecord
  has_many :amr_data_feed_readings
  has_many :amr_reading_warnings
  has_many :meters, -> { distinct }, through: :amr_data_feed_readings

  belongs_to :amr_data_feed_config

  scope :errored,       -> { where.not(error_messages: nil) }
  scope :successful,    -> { where(error_messages: nil) }
  scope :with_warnings, -> { includes(:amr_reading_warnings).where.not(amr_reading_warnings: { id: nil }) }
  scope :since,         ->(date) { where('import_time >= ?', date) }
end
