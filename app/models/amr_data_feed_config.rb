# == Schema Information
#
# Table name: amr_data_feed_configs
#
#  column_separator        :text             default(","), not null
#  created_at              :datetime         not null
#  date_format             :text             not null
#  description             :text             not null
#  handle_off_by_one       :boolean          default(FALSE)
#  header_example          :text
#  id                      :bigint(8)        not null, primary key
#  identifier              :text             not null
#  meter_description_field :text
#  mpan_mprn_field         :text             not null
#  msn_field               :text
#  number_of_header_rows   :integer          default(0), not null
#  postcode_field          :text
#  process_type            :integer          default("s3_folder"), not null
#  provider_id_field       :text
#  reading_date_field      :text             not null
#  reading_fields          :text             not null, is an Array
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
  enum process_type: [:s3_folder, :low_carbon_hub_api]
  enum source_type: [:email, :manual, :api, :sftp]

  validates :identifier, :description, uniqueness: true

  def map_of_fields_to_indexes(header = nil)
    this_header = header || header_example
    header_array = this_header.split(',')
    {
      mpan_mprn_index:    header_array.find_index(mpan_mprn_field),
      reading_date_index: header_array.find_index(reading_date_field),
      postcode_index: header_array.find_index(postcode_field),
      units_index: header_array.find_index(units_field),
      description_index: header_array.find_index(meter_description_field),
      total_index: header_array.find_index(total_field),
      meter_serial_number_index: header_array.find_index(msn_field),
      provider_record_id_index: header_array.find_index(provider_id_field)
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
end
