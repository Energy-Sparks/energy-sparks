class AmrReadingData
  include ActiveModel::Validations

  attr_accessor :reading_data, :date_format, :missing_reading_threshold

  ERROR_MISSING_MPAN = 'Mpan or MPRN field is missing'.freeze
  ERROR_MISSING_READING_DATE = 'Reading date is missing'.freeze
  ERROR_MISSING_READINGS = 'Some days have missing readings'.freeze
  ERROR_BAD_DATE_FORMAT = 'Bad format for some reading dates - for example here is one: %{example}'.freeze
  ERROR_UNABLE_TO_PARSE_FILE = 'Unable to parse the file'.freeze

  validate :missing_readings?
  validate :missing_mpan_mprn?
  validate :missing_reading_date?
  validate :invalid_reading_date?, unless: [:all_the_reading_dates_are_dates?, :there_are_any_missing_reading_dates?]
  validates_presence_of :reading_data, message: ERROR_UNABLE_TO_PARSE_FILE

  def initialize(reading_data:, date_format:, missing_reading_threshold: 0)
    @reading_data = reading_data
    @date_format = date_format
    @missing_reading_threshold = missing_reading_threshold
  end

  def error_messages_joined
    errors.messages[:reading_data].join(', ')
  end

  private

  def missing_readings?
    if less_than_48_readings? || blank_readings?
      errors.add(:reading_data, ERROR_MISSING_READINGS)
    end
  end

  def less_than_48_readings?
    @reading_data.detect { |reading| reading[:readings].compact.size < (48 - @missing_reading_threshold) }
  end

  def blank_readings?
    @reading_data.detect { |reading| reading[:readings].count(&:blank?) > @missing_reading_threshold }
  end

  def missing_mpan_mprn?
    if @reading_data.detect { |reading| reading[:mpan_mprn].blank? }
      errors.add(:reading_data, ERROR_MISSING_MPAN)
    end
  end

  def missing_reading_date?
    if there_are_any_missing_reading_dates?
      errors.add(:reading_data, ERROR_MISSING_READING_DATE)
    end
  end

  def there_are_any_missing_reading_dates?
    @reading_data.detect { |reading| reading[:reading_date].blank? }
  end

  def invalid_reading_date?
    is_there_an_invalid_reading_date?
  rescue ArgumentError => e
    errors.add(:reading_data, e.message)
  end

  def all_the_reading_dates_are_dates?
    @reading_data.reject { |reading| reading[:reading_date].instance_of? Date }.blank?
  end

  def is_there_an_invalid_reading_date?
    @reading_data.each { |reading| Date.strptime(reading[:reading_date], @date_format) }
  rescue ArgumentError
    lenient_date_checking
  end

  def lenient_date_checking
    date_record = nil
    @reading_data.each do |reading|
      date_record = reading[:reading_date]
      next if date_record.nil?
      Date.parse(date_record)
    end
  rescue ArgumentError
    raise ArgumentError, ERROR_BAD_DATE_FORMAT % { example: date_record }
  end
end
