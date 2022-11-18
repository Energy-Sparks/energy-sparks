class AmrReadingData
  include ActiveModel::Validations

  attr_accessor :reading_data, :date_format, :missing_reading_threshold

  WARNING_INCONSISTENT_DATE_FORMAT = 'Reading date format does not match configuration format'.freeze
  WARNING_BAD_DATE_FORMAT = 'Bad format for a reading date'.freeze
  WARNING_READING_DATE_MISSING = 'Reading date is missing'.freeze
  WARNING_READING_FUTURE_DATE = 'Reading date is in the future'.freeze
  WARNING_MISSING_MPAN_MPRN = 'Mpan or MPRN field is missing'.freeze
  WARNING_MISSING_READINGS = 'Missing readings (should be 48)'.freeze
  WARNING_DUPLICATE_READING = 'Another reading exists for the same Mpan or MPRN for the same date'.freeze

  ERROR_UNABLE_TO_PARSE_FILE = 'Unable to parse the file'.freeze

  WARNINGS = {
    inconsistent_reading_date_format: WARNING_INCONSISTENT_DATE_FORMAT,
    missing_readings: WARNING_MISSING_READINGS,
    missing_mpan_mprn: WARNING_MISSING_MPAN_MPRN,
    missing_reading_date: WARNING_READING_DATE_MISSING,
    invalid_reading_date: WARNING_BAD_DATE_FORMAT,
    future_reading_date: WARNING_READING_FUTURE_DATE,
    duplicate_reading: WARNING_DUPLICATE_READING
  }.freeze

  validates_presence_of :reading_data, message: ERROR_UNABLE_TO_PARSE_FILE
  validate :any_valid_readings?

  def initialize(reading_data:, date_format:, missing_reading_threshold: 0, today: Time.zone.today)
    @reading_data = reading_data
    @date_format = date_format
    @missing_reading_threshold = missing_reading_threshold
    @today = today
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
    @reading_data.each_with_index do |reading, index|
      reading_date = reading[:reading_date]
      readings = reading[:readings]

      warnings = []

      warnings << :missing_readings if missing_readings?(readings)
      warnings << :missing_mpan_mprn if reading[:mpan_mprn].blank?
      warnings << :missing_reading_date if reading_date.blank?
      warnings << :duplicate_reading if duplicate_reading?(reading, @reading_data[index + 1..-1])

      if reading_date.present? && valid_reading_date?(reading_date)
        warnings << :future_reading_date if future_reading_date?(reading_date)
        # warnings << :inconsistent_reading_date_format if inconsistent_reading_date_format?(reading_date)
      else
        warnings << :invalid_reading_date
      end

      reading[:warnings] = warnings if warnings.any?
    end
  end

  def inconsistent_reading_date_format?(reading_date)
    return false if reading_date.is_a? Date

    formatted_date = Date.strptime(reading_date, @date_format)
    return false if formatted_date.strftime(@date_format) == reading_date

    true
  rescue ArgumentError
    true
  end

  def missing_readings?(readings)
    readings.compact.count(&:present?) < (48 - @missing_reading_threshold)
  end

  def valid_reading_date?(reading_date)
    parse_date(reading_date).present?
  end

  def future_reading_date?(reading_date)
    parse_date(reading_date) > @today
  end

  def parse_date(reading_date)
    return reading_date if reading_date.is_a? Date
    Date.strptime(reading_date, @date_format)
  rescue ArgumentError
    begin
      Date.parse(reading_date)
    rescue ArgumentError
      nil
    end
  end

  def duplicate_reading?(reading, remainder)
    remainder.any? do |other_reading|
      other_reading[:mpan_mprn] == reading[:mpan_mprn] &&
        other_reading[:reading_date] == reading[:reading_date]
    end
  end
end
