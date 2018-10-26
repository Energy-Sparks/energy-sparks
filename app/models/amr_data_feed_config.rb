# == Schema Information
#
# Table name: amr_data_feed_configs
#
#  access_type             :text             not null
#  archive_bucket          :text             not null
#  area_id                 :bigint(8)
#  bucket                  :text             not null
#  created_at              :datetime         not null
#  date_format             :text             not null
#  description             :text             not null
#  headers_example         :text
#  id                      :bigint(8)        not null, primary key
#  meter_description_field :text
#  mpan_mprn_field         :text             not null
#  msn_field               :text
#  postcode_field          :text
#  provider_id_field       :text
#  reading_date_field      :text             not null
#  reading_fields          :text             not null, is an Array
#  total_field             :text
#  units_field             :text
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_amr_data_feed_configs_on_area_id  (area_id)
#

class AmrDataFeedConfig < ApplicationRecord
  def self.set_up_banes
    if where(description: 'Banes', access_type: 'SFTP').exists?
      find_by(description: 'Banes', access_type: 'SFTP')
    else
      self.create(
        area_id: 2,
        description: 'Banes',
        bucket: 'amr_files_bucket',
        archive_bucket: 'archive',
        access_type: 'SFTP',
        date_format: "%b %e %Y %I:%M%p",
        mpan_mprn_field: 'M1_Code1',
        reading_date_field: 'Date',
        reading_fields: "[00:30],[01:00],[01:30],[02:00],[02:30],[03:00],[03:30],[04:00],[04:30],[05:00],[05:30],[06:00],[06:30],[07:00],[07:30],[08:00],[08:30],[09:00],[09:30],[10:00],[10:30],[11:00],[11:30],[12:00],[12:30],[13:00],[13:30],[14:00],[14:30],[15:00],[15:30],[16:00],[16:30],[17:00],[17:30],[18:00],[18:30],[19:00],[19:30],[20:00],[20:30],[21:00],[21:30],[22:00],[22:30],[23:00],[23:30],[24:00]".split(','),
        msn_field: 'M1_Code2',
        provider_id_field: 'ID',
        total_field: 'Total Units',
        meter_description_field: 'Location',
        postcode_field: 'PostCode',
        units_field: 'Units',
        headers_example: "ID,Date,Location,Type,PostCode,Units,Total Units,[00:30],[01:00],[01:30],[02:00],[02:30],[03:00],[03:30],[04:00],[04:30],[05:00],[05:30],[06:00],[06:30],[07:00],[07:30],[08:00],[08:30],[09:00],[09:30],[10:00],[10:30],[11:00],[11:30],[12:00],[12:30],[13:00],[13:30],[14:00],[14:30],[15:00],[15:30],[16:00],[16:30],[17:00],[17:30],[18:00],[18:30],[19:00],[19:30],[20:00],[20:30],[21:00],[21:30],[22:00],[22:30],[23:00],[23:30],[24:00],M1_Code1,M1_Code2"
      )
    end
  end

  def map_of_fields_to_indexes(header = nil)
 #   header =
    this_header = header || headers_example
    header_array = this_header.split(',')
    {
      mpan_mprn_index:    header_array.find_index(mpan_mprn_field),
      reading_date_index: header_array.find_index(reading_date_field),
      postcode_index: header_array.find_index(postcode_field),
      #school_index: header_array.find_index(school_field),
      units_index: header_array.find_index(units_field),
      description_index: header_array.find_index(meter_description_field),
      total_index: header_array.find_index(total_field),
      meter_serial_number_index: header_array.find_index(msn_field),
      provider_record_id_index: header_array.find_index(provider_id_field)
    }
  end

  def range_of_readings(header = nil)
 #   header = "ID,Date,Location,Type,PostCode,Units,Total Units,[00:30],[01:00],[01:30],[02:00],[02:30],[03:00],[03:30],[04:00],[04:30],[05:00],[05:30],[06:00],[06:30],[07:00],[07:30],[08:00],[08:30],[09:00],[09:30],[10:00],[10:30],[11:00],[11:30],[12:00],[12:30],[13:00],[13:30],[14:00],[14:30],[15:00],[15:30],[16:00],[16:30],[17:00],[17:30],[18:00],[18:30],[19:00],[19:30],[20:00],[20:30],[21:00],[21:30],[22:00],[22:30],[23:00],[23:30],[24:00],M1_Code1,M1_Code2"
    this_header = header || headers_example
    header_array = this_header.split(',')
    first_reading = header_array.find_index(reading_fields.first)
    last_reading = header_array.find_index(reading_fields.last)

    (first_reading..last_reading)
  end
end


#  id                      :bigint(8)        not null, primary key
#  amr_data_feed_config_id :integer          not null
#  meter_id                :integer
#  mpan_mprn               :bigint(8)        not null
#  reading_date            :date             not null
#  readings                :decimal(, )      not null, is an Array
#  postcode                :text
#  school                  :text
#  description             :text
#  units                   :text
#  total                   :decimal(, )
#  meter_serial_number     :text
#  provider_record_id      :text
#  type


# ID,Date,Location,Type,PostCode,Units,Total Units,[00:30],[01:00],[01:30],[02:00],[02:30],[03:00],[03:30],[04:00],[04:30],[05:00],[05:30],[06:00],[06:30],[07:00],[07:30],[08:00],[08:30],[09:00],[09:30],[10:00],[10:30],[11:00],[11:30],[12:00],[12:30],[13:00],[13:30],[14:00],[14:30],[15:00],[15:30],[16:00],[16:30],[17:00],[17:30],[18:00],[18:30],[19:00],[19:30],[20:00],[20:30],[21:00],[21:30],[22:00],[22:30],[23:00],[23:30],[24:00],M1_Code1,M1_Code2

# "59d21d2b33942ec3d1106ed2126c6b6b","Sep  3 2018 12:00AM","High Littleton C of E Primary School (Academy)","Electricity","BS39 6HF","kWh","24.871","0.165","0.183","0.062","0.068","0.067","0.063","0.093","0.117","0.43","0.068","0.074","0.321","0.929","0.759","0.928","0.7","0.728","0.723","1.051","0.885","0.828","1.048","0.823","0.969","1.098","0.869","0.909","0.952","1.187","0.907","1.092","1.325","0.913","0.853","0.269","0.254","0.274","0.156","0.151","0.448","0.134","0.122","0.243","0.122","0.122","0.116","0.122","0.151","2200012030347","E10BG50326"
