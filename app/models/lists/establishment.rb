# == Schema Information
#
# Table name: lists_establishments
#
#  address3                        :string
#  administrative_ward_code        :string
#  boarders_code                   :integer
#  census_date                     :datetime
#  close_date                      :datetime
#  county_name                     :string
#  created_at                      :datetime         not null
#  diocese_code                    :string
#  district_administrative_code    :string
#  easting                         :integer
#  establishment_name              :string
#  establishment_number            :integer
#  establishment_status_code       :integer
#  establishment_type_group_code   :integer
#  federations_code                :integer
#  fsm                             :integer
#  gor_code                        :string
#  gssla_code_name                 :string
#  id                              :bigint(8)        not null, primary key
#  la_code                         :integer
#  last_changed_date               :datetime
#  locality                        :string
#  lsoa_code                       :string
#  msoa_code                       :string
#  northing                        :integer
#  number_of_pupils                :integer
#  nursery_provision_name          :string
#  official_sixth_form_code        :integer
#  open_date                       :datetime
#  parliamentary_constituency_code :string
#  percentage_fsm                  :string
#  phase_of_education_code         :integer
#  postcode                        :string
#  previous_la_code                :integer
#  school_capacity                 :integer
#  school_website                  :string
#  statutory_high_age              :integer
#  statutory_low_age               :integer
#  street                          :string
#  town                            :string
#  trusts_code                     :integer
#  type_of_establishment_code      :integer
#  ukprn                           :integer
#  updated_at                      :datetime         not null
#  uprn                            :string
#  urban_rural_code                :string
#
module Lists
  class Establishment < ApplicationRecord
    self.table_name = 'lists_establishments'

    def self.import_from_zip(path, batch_size)
      Lists::Establishment.import(read_data_csv_from_zip(path), batch_size)
    end

    # Converts headers from camelcase to snakecase
    def self.convert_header(str)
      str.underscore.sub(' ', '_').remove('(', ')')
    end

    def self.read_data_csv_from_zip(path)
      Zip::File.open(path) do |zip|
        zip.each do |file|
          if file.name.start_with?('edubasealldata')
            return file.get_input_stream.read.force_encoding(Encoding::ISO_8859_1)
          end
        end
        raise LoadError.new("Couldn't find file beginning with \"edubasealldata\" in #{path}")
      end
    end

    def self.import(csv_str, batch_size)
      rows = CSV.parse(csv_str, headers: true)

      # Keys are headers from the CSV that match a database column when converted
      headers_to_attributes = rows.first.headers.filter_map do |h|
        [h, convert_header(h)] if Establishment.column_names.include?(convert_header(h))
      end.to_h
      headers_to_attributes['URN'] = 'id' # URN is the only header mapped to a column that isn't just the header in snakecase

      rows.map { |row| create_from_row(row, headers_to_attributes) }.each_slice(batch_size) { |batch| upsert_batch(batch) }

      puts 'Finished successfully'
    end

    private_class_method def self.upsert_batch(batch)
      puts "Upserting batch of #{batch.length} entries"
      upsert_all(batch, unique_by: 'id')
    end

    private_class_method def self.create_from_row(row, headers_to_attributes)
      ret = {}
      headers_to_attributes.each_key do |h|
        # Use model attributes to detect which type to cast to
        case attribute_types[headers_to_attributes[h]]
        when ActiveModel::Type::Integer
          ret[headers_to_attributes[h]] = row[h].to_i
        when ActiveModel::Type::String
          ret[headers_to_attributes[h]] = row[h]
        when ActiveRecord::AttributeMethods::TimeZoneConversion::TimeZoneConverter
          if row[h] == ''
            ret[headers_to_attributes[h]] = nil
          else
            ret[headers_to_attributes[h]] = DateTime.parse(row[h])
          end
        end
      end
      return ret
    end
  end
end
