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

    has_many :links, class_name: 'Lists::EstablishmentLink'

    def open?
      close_date.nil?
    end

    def closed?
      !open?
    end

    # Use the links table to find this establishment's successor. Will fail if it doesn't have one
    def successor
      link = links.filter(&:successor?).first
      link.nil? ? nil : link.linked_establishment
    end

    # Skip through all links to get the most up-to-date establishment
    def current_establishment
      if open?
        self
      else
        s = successor # may be nil, like in the case of an establishment that has closed and not been reopened
        s.nil? ? self : s.current_establishment
      end
    end

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

      # Array of pairs mapping headers from the CSV that match a database column when converted
      headers_to_attributes = rows.first.headers.filter_map do |h|
        [h, convert_header(h)] if Establishment.column_names.include?(convert_header(h))
      end
      headers_to_attributes.append(['URN', 'id']) # URN is the only header mapped to a column that isn't just the header in snakecase

      rows.map { |row| create_from_row(row, headers_to_attributes) }.each_slice(batch_size) { |batch| upsert_batch(batch) }

      puts 'Finished successfully'
    end

    def self.find_establishment_id_for_school(sch, stats)
      if exists?(sch.urn)
        stats[:perfect] += 1
        est = find(sch.urn)
        return est.current_establishment.id
      end

      match = find_by('la_code::text || establishment_number::text = ?', sch.urn)
      if match != nil
        stats[:la_plus_en] += 1
        return match.current_establishment.id
      end

      puts "Warning: Couldn\'t match school with ID #{sch.id} and URN #{sch.urn} to any establishment!"
      stats[:unmatched] += 1
    end

    private_class_method def self.upsert_batch(batch)
      puts "Upserting batch of #{batch.length} entries to Lists::Establishments"
      upsert_all(batch, unique_by: 'id')
    end

    private_class_method def self.create_from_row(row, headers_to_attributes)
      headers_to_attributes.to_h do |header, attr_name|
        [attr_name, attribute_types[attr_name].cast(row[header])]
      end
    end
  end
end
