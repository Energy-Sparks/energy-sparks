class AmrReadingData
  include ActiveModel::Validations

  attr_accessor :reading_data, :date_format, :missing_reading_threshold

  # ERROR_BAD_DATE_FORMAT = 'Bad format for some reading dates - for example here is one: %{example}'.freeze
  ERROR_UNABLE_TO_PARSE_FILE = 'Unable to parse the file'.freeze

  WARNINGS = {
    blank_readings: 'Some days have blank readings',
    missing_readings: 'Some days have missing readings',
    missing_mpan_mprn: 'Mpan or MPRN field is missing',
    missing_reading_date: 'Reading date is missing',
    invalid_reading_date: 'Bad format for a reading data'
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
    @reading_data.any? { |reading| reading.key?(:warning) }
  end

  def warnings
    @reading_data.select { |reading| reading.key?(:warning) }
  end

  def valid_records
    @reading_data.reject { |reading| reading.key?(:warning) }
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
      mpan_mprn = reading[:mpan_mprn]
      reading_date = reading[:reading_date]
      readings = reading[:readings]

      if blank_readings?(readings)
        reading[:warning] = :blank_readings
      elsif missing_readings?(readings)
        reading[:warning] = :missing_readings
      elsif mpan_mprn.blank?
        reading[:warning] = :missing_mpan_mprn
      elsif reading_date.blank?
        reading[:warning] = :missing_reading_date
      elsif ! valid_reading_date?(reading_date)
        reading[:warning] = :invalid_reading_date
      end
    end
  end

  def blank_readings?(readings)
    readings.count(&:blank?) > @missing_reading_threshold
  end

  def missing_readings?(readings)
    readings.compact.size < (48 - @missing_reading_threshold)
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
