class AmrReadingData
  include ActiveModel::Validations

  attr_accessor :reading_data, :date_format

  ERROR_MISSING_MPAN = 'Mpan or MPRN field is missing'.freeze
  ERROR_MISSING_READING_DATE = 'Reading date is missing'.freeze
  ERROR_MISSING_READINGS = 'Some days have missing readings'.freeze
  ERROR_BAD_DATE_FORMAT = 'Bad format for some reading dates - for example here is one: %{example}'.freeze
  ERROR_UNABLE_TO_PARSE_FILE = 'Unable to parse the file'.freeze

  validate :missing_readings?
  validate :missing_mpan_mprn?
  validate :missing_reading_date?
  validate :invalid_reading_date?
  validates_presence_of :reading_data, message: ERROR_UNABLE_TO_PARSE_FILE

  def initialize(reading_data:, date_format:)
    @reading_data = reading_data
    @date_format = date_format
  end

  private

  def missing_readings?
    if @reading_data.detect { |reading| reading[:readings].compact.size != 48 }
      errors.add(:reading_data, ERROR_MISSING_READINGS)
    end
  end

  def missing_mpan_mprn?
    if @reading_data.detect { |reading| reading[:mpan_mprn].blank? }
      errors.add(:reading_data, ERROR_MISSING_MPAN)
    end
  end

  def missing_reading_date?
    if @reading_data.detect { |reading| reading[:reading_date].blank? }
      errors.add(:reading_data, ERROR_MISSING_READING_DATE)
    end
  end

  def invalid_reading_date?
    return false if all_the_reading_dates_are_dates?
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
