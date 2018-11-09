# == Schema Information
#
# Table name: amr_data_feed_configs
#
#  access_type             :text             not null
#  area_id                 :bigint(8)
#  created_at              :datetime         not null
#  date_format             :text             not null
#  description             :text             not null
#  headers_example         :text
#  id                      :bigint(8)        not null, primary key
#  local_bucket_path       :text             not null
#  meter_description_field :text
#  mpan_mprn_field         :text             not null
#  msn_field               :text
#  postcode_field          :text
#  provider_id_field       :text
#  reading_date_field      :text             not null
#  reading_fields          :text             not null, is an Array
#  s3_archive_folder       :text             not null
#  s3_folder               :text             not null
#  total_field             :text
#  units_field             :text
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_amr_data_feed_configs_on_area_id  (area_id)
#

class AmrDataFeedConfig < ApplicationRecord
  def map_of_fields_to_indexes(header = nil)
    this_header = header || headers_example
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

  def range_of_readings(header = nil)
    this_header = header || headers_example
    header_array = this_header.split(',')
    first_reading = header_array.find_index(reading_fields.first)
    last_reading = header_array.find_index(reading_fields.last)

    (first_reading..last_reading)
  end
end
