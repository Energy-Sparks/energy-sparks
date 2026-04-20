# == Schema Information
#
# Table name: amr_reading_warnings
#
#  id                          :bigint           not null, primary key
#  fuel_type                   :string
#  mpan_mprn                   :text
#  reading_date                :text
#  readings                    :text             is an Array
#  warning                     :integer
#  warning_message             :text
#  warning_types               :integer          is an Array
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  amr_data_feed_import_log_id :bigint           not null
#  school_id                   :integer
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
  belongs_to :school, optional: true

  WARNINGS = {
    0 => :blank_readings,
    1 => :missing_readings,
    2 => :missing_mpan_mprn,
    3 => :missing_reading_date,
    4 => :invalid_reading_date,
    5 => :future_reading_date,
    6 => :duplicate_reading
  }.freeze

  enum :warning, { blank_readings: 0, missing_readings: 1, missing_mpan_mprn: 2, missing_reading_date: 3,
                   invalid_reading_date: 4 }

  def messages
    warning_symbols.map { |warning_symbol| AmrReadingData::WARNINGS[warning_symbol] }.join(', ')
  end

  def warning_symbols
    warning_types.map { |warning_type| WARNINGS[warning_type] }
  end
end
