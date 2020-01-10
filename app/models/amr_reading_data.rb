class AmrReadingData
  include ActiveModel::Validations

  attr_accessor :reading_data, :date_format, :missing_reading_threshold

  ERROR_MISSING_MPAN = 'Mpan or MPRN field is missing'.freeze
  ERROR_MISSING_READING_DATE = 'Reading date is missing'.freeze
  ERROR_MISSING_READINGS = 'Some days have missing readings'.freeze
  ERROR_BAD_DATE_FORMAT = 'Bad format for some reading dates - for example here is one: %{example}'.freeze
  ERROR_UNABLE_TO_PARSE_FILE = 'Unable to parse the file'.freeze

  #validate :missing_readings?
  # validate :missing_mpan_mprn?
  # validate :missing_reading_date?
  # validate :invalid_reading_date?, unless: [:all_the_reading_dates_are_dates?, :there_are_any_missing_reading_dates?]
  validates_presence_of :reading_data, message: ERROR_UNABLE_TO_PARSE_FILE

  def initialize(reading_data:, date_format:, missing_reading_threshold: 0)
    @reading_data = reading_data
    @date_format = date_format
    @missing_reading_threshold = missing_reading_threshold

    invalid_row_check
  end

  def warnings?
    @reading_data.any? { |reading| reading.key?(:warning) }
  end

  def warnings
    @reading_data.select { |reading| reading.key?(:warning) }
  end

  def valid_reading_count
    reading_count - warnings.size
  end

  def reading_count
    @reading_data.size
  end

  private

  def count_rows_with_missing_half_hours
    @reading_data.count { |reading| reading[:readings].compact.size < (48 - @missing_reading_threshold) }
  end

  def count_rows_with_blank_readings
    @reading_data.count { |reading| reading[:readings].count(&:blank?) > @missing_reading_threshold }
  end

  def blank_readings?(readings)
    readings.count(&:blank?) > @missing_reading_threshold
  end

  def missing_readings?(readings)
    readings.compact.size < (48 - @missing_reading_threshold)
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
