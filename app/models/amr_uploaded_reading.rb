# == Schema Information
#
# Table name: amr_uploaded_readings
#
#  amr_data_feed_config_id :bigint(8)        not null
#  created_at              :datetime         not null
#  file_name               :text             default("f"), not null
#  id                      :bigint(8)        not null, primary key
#  imported                :boolean          default(FALSE), not null
#  reading_data            :json             not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_amr_uploaded_readings_on_amr_data_feed_config_id  (amr_data_feed_config_id)
#
# Foreign Keys
#
#  fk_rails_...  (amr_data_feed_config_id => amr_data_feed_configs.id) ON DELETE => cascade
#

class AmrUploadedReading < ApplicationRecord
  belongs_to :amr_data_feed_config

  validates_presence_of :file_name

  validate :validate_reading_data, on: :validate_reading_data

  ERROR_MISSING_MPAN = 'Mpan or MPRN field is missing'.freeze
  ERROR_MISSING_READING_DATE = 'Reading date is missing'.freeze
  ERROR_MISSING_READINGS = 'Some days have missing readings'.freeze
  ERROR_BAD_DATE_FORMAT = 'Bad format for some reading dates - for example %{example}'.freeze
  ERROR_UNABLE_TO_PARSE_FILE = 'Unable to parse the file'.freeze

  def validate_reading_data
    errors[:base] << ERROR_UNABLE_TO_PARSE_FILE if reading_data.empty?
    errors[:base] << ERROR_MISSING_MPAN if check_whether_any_missing?('mpan_mprn')

    errors[:base] << ERROR_MISSING_READING_DATE if check_whether_any_missing?('reading_date')
    errors[:base] << ERROR_MISSING_READINGS if missing_readings?

    begin
      is_there_an_invalid_reading_date
    rescue ArgumentError => e
      errors[:base] << e.message
    end
  end

  private

  def missing_readings?
    reading_data.detect { |reading| reading['readings'].compact.size != 48 }
  end

  def check_whether_any_missing?(key)
    reading_data.detect { |reading| reading[key].blank? }
  end

  def is_there_an_invalid_reading_date
    reading_data.each { |reading| Date.strptime(reading['reading_date'], amr_data_feed_config.date_format) }
  rescue ArgumentError
    lenient_date_checking
  end

  def lenient_date_checking
    date_record = nil
    reading_data.each do |reading|
      date_record = reading['reading_date']
      next if date_record.nil?
      Date.parse(date_record)
    end
  rescue ArgumentError
    raise ArgumentError, ERROR_BAD_DATE_FORMAT % { example: date_record }
  end
end
