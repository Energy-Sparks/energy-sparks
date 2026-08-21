# frozen_string_literal: true

# == Schema Information
#
# Table name: amr_data_feed_configs
#
#  id                      :bigint(8)        not null, primary key
#  allow_merging           :boolean          default(FALSE), not null
#  column_row_filters      :jsonb
#  column_separator        :text             default(","), not null
#  convert_to_kwh          :enum             default("no")
#  date_format             :text             not null
#  delayed_reading         :boolean          default(FALSE), not null
#  description             :text             not null
#  enabled                 :boolean          default(TRUE), not null
#  estimate_flags          :string           default([]), not null, is an Array
#  expected_units          :string
#  half_hourly_labelling   :enum
#  handle_off_by_one       :boolean          default(FALSE)
#  header_example          :text
#  identifier              :text             not null
#  lookup_by_serial_number :boolean          default(FALSE)
#  missing_reading_window  :integer          default(5)
#  missing_readings_limit  :integer
#  mpan_mprn_field         :text             not null
#  msn_field               :text
#  number_of_header_rows   :integer          default(0), not null
#  period_field            :string
#  positional_index        :boolean          default(FALSE), not null
#  process_type            :integer          default(0), not null
#  reading_date_field      :text             not null
#  reading_fields          :text             not null, is an Array
#  reading_status_fields   :string           default([]), not null, is an Array
#  reading_time_field      :text
#  repeated_names          :boolean          default(FALSE), not null
#  row_per_reading         :boolean          default(FALSE), not null
#  source_type             :integer          default(0), not null
#  units_field             :text
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  owned_by_id             :bigint(8)
#
# Indexes
#
#  index_amr_data_feed_configs_on_description  (description) UNIQUE
#  index_amr_data_feed_configs_on_identifier   (identifier) UNIQUE
#  index_amr_data_feed_configs_on_owned_by_id  (owned_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (owned_by_id => users.id)
#

class AmrDataFeedConfig < ApplicationRecord # rubocop:todo Metrics/ClassLength
  ESTIMATED_STATUS = Set['E', 'Estimate', 'Estimated']

  scope :enabled,           -> { where(enabled: true) }
  scope :allow_manual,      -> { enabled.where.not(source_type: :api) }

  scope :stopped_feeds, lambda {
    where(<<~SQL.squish)
      (
        SELECT r.updated_at
        FROM amr_data_feed_readings r
        WHERE r.amr_data_feed_config_id = amr_data_feed_configs.id
        ORDER BY r.updated_at DESC
        LIMIT 1
      ) < (NOW() - (amr_data_feed_configs.missing_reading_window * INTERVAL '1 day'))
    SQL
  }

  enum :process_type, { s3_folder: 0, low_carbon_hub_api: 1, solar_edge_api: 2, n3rgy_api: 3, rtone_variant_api: 4,
                        other_api: 5 }
  enum :source_type, { email: 0, manual: 1, api: 2, sftp: 3 }
  enum :convert_to_kwh, %i[no m3 meter].index_with(&:to_s), prefix: true

  belongs_to :owned_by, class_name: :User, optional: true
  has_many :amr_data_feed_import_logs
  has_many :meters, -> { distinct }, through: :amr_data_feed_import_logs
  has_many :amr_data_feed_readings

  has_rich_text :notes

  validates :identifier, :description, uniqueness: true, presence: true
  validates :row_per_reading, inclusion: [true], if: :positional_index
  validates :msn_field, presence: { if: :lookup_by_serial_number }

  validate :period_or_time_field, if: :positional_index
  validate :no_missing_reading_indexes, if: :header_example
  validate :source_and_process_type

  BLANK_THRESHOLD = 1

  YEAR_MONTH_DAY_FORMATS = ['%Y-%m-%d', '%Y/%m/%d'].freeze
  DAY_MONTH_YEAR_FORMATS = ['%d/%m/%Y', '%d-%m-%Y'].freeze
  FOUR_DIGIT_YEAR = %r{\A\d{2}(?:-|/)\d{2}(?:-|/)\d{4}\z}
  TWO_DIGIT_YEAR  = %r{\A\d{2}(?:-|/)\d{2}(?:-|/)\d{2}\z}

  # Turns a formatted date into a Date.
  #
  # In general we parse according to the specified date format. But in some cases the format of the strings
  # changes in the received data, or a user uploads data using an incorrect format. So the formats may not
  # match.
  #
  # This can lead to two problems:
  #
  # 1. Date.strptime parses date_string without error, but the date is wrong
  # 2. Date.strptime fails to parse data_string, throwing an error.
  #
  # To handle the first scenario to look for two specific cases where the interpretation can go wrong and
  # parse the dates differently.
  #
  # In the second we fallback to Date.parse
  def self.date_from_string_using_date_format(date_string, date_format)
    return nil if date_string.blank?

    safe_parse_date(date_string, date_format)
  rescue ArgumentError
    begin
      Date.parse(date_string)
    rescue ArgumentError
      nil
    end
  end

  private_class_method def self.safe_parse_date(date_string, date_format)
    # Avoids this: Date.strptime('12-05-2022', "%Y-%m-%d") => Fri, 20 May 0012
    return Date.parse(date_string) if YEAR_MONTH_DAY_FORMATS.include?(date_format) && date_string.match(FOUR_DIGIT_YEAR)

    # Avoids this: Date.strptime('12-05-22', "%d-%m-%Y") => Fri, 20 May 0012
    # And this: Date.parse('12-05-22') => Tue, 22 May 2012
    if DAY_MONTH_YEAR_FORMATS.include?(date_format) && date_string.match(TWO_DIGIT_YEAR)
      format = date_string.include?('/') ? '%d/%m/%y' : '%d-%m-%y'
      return Date.strptime(date_string, format)
    end

    Date.strptime(date_string, date_format)
  end

  def latest_reading_date
    amr_data_feed_readings.maximum(:updated_at)
  end

  def period_or_time_field
    return unless positional_index && reading_time_field.blank? && period_field.blank?

    errors.add(:base, 'Must specify either period or time field')
  end

  def map_of_fields_to_indexes(header = nil)
    this_header = header || header_example
    header_array = this_header.split(',')
    {
      meter_serial_number_index: header_array.find_index(msn_field),
      mpan_mprn_index: header_array.find_index(mpan_mprn_field),
      period_index: header_array.find_index(period_field),
      reading_date_index: header_array.find_index(reading_date_field),
      reading_time_index: header_array.find_index(reading_time_field),
      units_index: header_array.find_index(units_field)
    }
  end

  def reading_indexes(header = nil)
    header_array = header_array(header)
    reading_fields.map { |reading_header| header_array.find_index(reading_header) }
  end

  def reading_status_indexes(header = nil)
    header_array = header_array(header)

    reading_status_fields.flat_map do |field|
      all_indexes = header_array.each_index.select { |i| header_array[i] == field }

      # for rare scenario where the reading fields and status fields have the same names
      # first block of columns is reading, second block is status
      if repeated_names
        all_indexes.last
      else
        all_indexes
      end
    end
  end

  def header_first_thing
    header_example.split(',').first
  end

  def mpan_mprn_index
    map_of_fields_to_indexes[:mpan_mprn_index]
  end

  def s3_archive_folder
    "archive-#{identifier}"
  end

  # Used in SingleReadConverter to determine whether to drop rows that have missing readings
  #
  # Only applicable to row_per_reading formats
  #
  # To preserve current loader behaviour this returns either the value of missing_readings_limit, to
  # allow that to be configured, or a default of 1
  #
  # This can later be replaced with missing_reading_limit, but need to resolve how row_per_reading
  # formats can produce days with missing readings due to handling of 23:30-00:00 half-hour.
  def blank_threshold
    return nil unless row_per_reading?

    missing_readings_limit || BLANK_THRESHOLD
  end

  private

  def header_array(header = nil)
    this_header = header || header_example
    this_header.split(',')
  end

  def no_missing_reading_indexes
    return unless reading_indexes.include?(nil)

    errors.add(:header_example, "can't find all reading_fields in header_example")
  end

  def source_and_process_type
    return unless process_type != 's3_folder' && source_type != 'api'

    errors.add(:source_type, 'source_api should be api if process_type is an api')
  end
end
