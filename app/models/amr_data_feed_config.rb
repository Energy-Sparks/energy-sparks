# == Schema Information
#
# Table name: amr_data_feed_configs
#
#  column_row_filters      :jsonb
#  column_separator        :text             default(","), not null
#  convert_to_kwh          :boolean          default(FALSE)
#  created_at              :datetime         not null
#  date_format             :text             not null
#  delayed_reading         :boolean          default(FALSE), not null
#  description             :text             not null
#  enabled                 :boolean          default(TRUE), not null
#  expected_units          :string
#  handle_off_by_one       :boolean          default(FALSE)
#  header_example          :text
#  id                      :bigint(8)        not null, primary key
#  identifier              :text             not null
#  import_warning_days     :integer          default(10)
#  lookup_by_serial_number :boolean          default(FALSE)
#  meter_description_field :text
#  missing_readings_limit  :integer
#  mpan_mprn_field         :text             not null
#  msn_field               :text
#  number_of_header_rows   :integer          default(0), not null
#  period_field            :string
#  positional_index        :boolean          default(FALSE), not null
#  postcode_field          :text
#  process_type            :integer          default("s3_folder"), not null
#  provider_id_field       :text
#  reading_date_field      :text             not null
#  reading_fields          :text             not null, is an Array
#  reading_time_field      :text
#  row_per_reading         :boolean          default(FALSE), not null
#  source_type             :integer          default("email"), not null
#  total_field             :text
#  units_field             :text
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_amr_data_feed_configs_on_description  (description) UNIQUE
#  index_amr_data_feed_configs_on_identifier   (identifier) UNIQUE
#

class AmrDataFeedConfig < ApplicationRecord
  scope :enabled,           -> { where(enabled: true) }
  scope :allow_manual,      -> { enabled.where.not(source_type: :api) }

  enum process_type: [:s3_folder, :low_carbon_hub_api, :solar_edge_api, :n3rgy_api, :rtone_variant_api]
  enum source_type: [:email, :manual, :api, :sftp]

  has_many :amr_data_feed_import_logs
  has_many :meters, -> { distinct }, through: :amr_data_feed_import_logs

  has_rich_text :notes

  validates :identifier, :description, uniqueness: true
  validates_presence_of :identifier, :description

  BLANK_THRESHOLD = 1

  def map_of_fields_to_indexes(header = nil)
    this_header = header || header_example
    header_array = this_header.split(',')
    {
      mpan_mprn_index:    header_array.find_index(mpan_mprn_field),
      reading_date_index: header_array.find_index(reading_date_field),
      reading_time_index: header_array.find_index(reading_time_field),
      postcode_index: header_array.find_index(postcode_field),
      units_index: header_array.find_index(units_field),
      description_index: header_array.find_index(meter_description_field),
      total_index: header_array.find_index(total_field),
      meter_serial_number_index: header_array.find_index(msn_field),
      provider_record_id_index: header_array.find_index(provider_id_field),
      period_index: header_array.find_index(period_field)
    }
  end

  def array_of_reading_indexes(header = nil)
    this_header = header || header_example
    header_array = this_header.split(',')
    reading_fields.map { |reading_header| header_array.find_index(reading_header) }
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

  def local_bucket_path
    path = ENV['AMR_CONFIG_LOCAL_FILE_BUCKET_PATH'] || 'tmp/amr_files_bucket'
    "#{path}/#{identifier}"
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
    return missing_readings_limit || BLANK_THRESHOLD
  end
end
