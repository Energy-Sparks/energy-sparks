class AmrReadingData
  include ActiveModel::Validations

  attr_accessor :reading_data, :date_format, :missing_reading_threshold

  WARNING_BAD_DATE_FORMAT = 'Bad format for a reading date'.freeze
  WARNING_READING_DATE_MISSING = 'Reading date is missing'.freeze
  WARNING_MISSING_MPAN_MPRN = 'Mpan or MPRN field is missing'.freeze
  WARNING_MISSING_READINGS = 'Missing readings (should be 48)'.freeze

  ERROR_UNABLE_TO_PARSE_FILE = 'Unable to parse the file'.freeze

  WARNINGS = {
    missing_readings: WARNING_MISSING_READINGS,
    missing_mpan_mprn: WARNING_MISSING_MPAN_MPRN,
    missing_reading_date: WARNING_READING_DATE_MISSING,
    invalid_reading_date: WARNING_BAD_DATE_FORMAT
  }.freeze

  validates_presence_of :reading_data, message: ERROR_UNABLE_TO_PARSE_FILE
  validate :any_valid_readings?

  def initialize(reading_data:, date_format:, missing_reading_threshold: 0)
    @reading_data = reading_data
    @date_format = date_format
    @missing_reading_threshold = missing_reading_threshold
    invalid_row_check
  end

  def error_messages_joined
    errors.messages[:reading_data].uniq.join(', ')
  end

  def warnings?
    @reading_data.any? { |reading| reading.key?(:warnings) }
  end

  def warnings
    @reading_data.select { |reading| reading.key?(:warnings) }
  end

  def valid_records
    @reading_data.reject { |reading| reading.key?(:warnings) }
  end

  def valid_reading_count
    reading_count - warnings.size
  end

  def reading_count
    @reading_data.size
  end

  private

  def any_valid_readings?
    if valid_reading_count == 0
      errors.add(:reading_data, ERROR_UNABLE_TO_PARSE_FILE)
    end
  end

  def invalid_row_check
    @reading_data.each do |reading|
      reading_date = reading[:reading_date]
      readings = reading[:readings]

      warnings = []

      warnings << :missing_readings if missing_readings?(readings)
      warnings << :missing_mpan_mprn if reading[:mpan_mprn].blank?
      warnings << :missing_reading_date if reading_date.blank?
      warnings << :invalid_reading_date unless reading_date.present? && valid_reading_date?(reading_date)

      reading[:warnings] = warnings if warnings.any?
    end
  end

  def missing_readings?(readings)
    readings.compact.count(&:present?) < (48 - @missing_reading_threshold)
  end

  def valid_reading_date?(reading_date)
    return true if reading_date.is_a? Date
    Date.strptime(reading_date, @date_format)
  rescue ArgumentError
    begin
      Date.parse(reading_date)
    rescue ArgumentError
      false
    end
  end
end
