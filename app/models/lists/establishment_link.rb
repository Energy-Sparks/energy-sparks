# == Schema Information
#
# Table name: lists_establishment_links
#
#  link_established_date :datetime
#  link_name             :string
#  link_type             :string
#  link_urn              :integer          not null, primary key
#  urn                   :integer          not null, primary key
#
module Lists
  class EstablishmentLink < ApplicationRecord
    self.table_name = 'lists_establishment_links'

    def establishment
      Lists::Establishment.find(urn)
    end

    def linked_establishment
      Lists::Establishment.find(link_urn)
    end

    def successor?
      link_type.start_with?('Successor')
    end

    def self.import_from_zip(path, batch_size)
      EstablishmentLink.import(read_data_csv_from_zip(path), batch_size)
    end

    # Converts headers from camelcase to snakecase
    def self.convert_header(str)
      str.underscore.sub(' ', '_').remove('(', ')')
    end

    def self.read_data_csv_from_zip(path)
      Zip::File.open(path) do |zip|
        zip.each do |file|
          if file.name.start_with?('links_edubasealldata')
            return file.get_input_stream.read.force_encoding(Encoding::ISO_8859_1)
          end
        end
        raise LoadError.new("Couldn't find file beginning with \"links_edubasealldata\" in #{path}")
      end
    end

    def self.import(csv_str, batch_size)
      rows = CSV.parse(csv_str, headers: true)

      # Array of pairs mapping headers from the CSV that match a database column when converted
      headers_to_attributes = rows.first.headers.filter_map do |h|
        [h, convert_header(h)] if EstablishmentLink.column_names.include?(convert_header(h))
      end

      rows.map { |row| create_from_row(row, headers_to_attributes) }.each_slice(batch_size) { |batch| upsert_batch(batch) }

      puts 'Finished successfully'
    end

    private_class_method def self.upsert_batch(batch)
      puts "Upserting batch of #{batch.length} entries to Lists::EstablishmentLinks"
      upsert_all(batch)
    end

    private_class_method def self.create_from_row(row, headers_to_attributes)
      headers_to_attributes.to_h do |header, attr_name|
        [attr_name, attribute_types[attr_name].cast(row[header])]
      end
    end
  end
end
