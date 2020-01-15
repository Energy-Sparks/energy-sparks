# == Schema Information
#
# Table name: amr_reading_warnings
#
#  amr_data_feed_import_log_id :bigint(8)        not null
#  created_at                  :datetime         not null
#  id                          :bigint(8)        not null, primary key
#  mpan_mprn                   :text
#  reading_date                :text
#  readings                    :text             is an Array
#  updated_at                  :datetime         not null
#  warning                     :integer
#  warning_message             :text
#
# Indexes
#
#  index_amr_reading_warnings_on_amr_data_feed_import_log_id  (amr_data_feed_import_log_id)
#
# Foreign Keys
#
#  fk_rails_...  (amr_data_feed_import_log_id => amr_data_feed_import_logs.id) ON DELETE => cascade
#

class AmrReadingWarning < ApplicationRecord
  belongs_to :amr_data_feed_import_log

  enum warning: [:blank_readings, :missing_readings, :missing_mpan_mprn, :missing_reading_date, :invalid_reading_date]
end
