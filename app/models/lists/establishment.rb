# == Schema Information
#
# Table name: lists_establishments
#
#  created_at                 :datetime         not null
#  establishment_name         :string
#  establishment_number       :integer
#  establishment_status_code  :integer
#  id                         :bigint(8)        not null, primary key
#  la_code                    :integer
#  last_changed_date          :datetime
#  number_of_pupils           :integer
#  percentage_fsm             :string
#  postcode                   :string
#  school_website             :string
#  type_of_establishment_code :integer
#  updated_at                 :datetime         not null
#  uprn                       :string
#
module Lists
  class Establishment < ApplicationRecord
    self.table_name = 'lists_establishments'

    def self.import_from_zip(path, batch_size)
      Lists::Establishment.import(read_data_csv_from_zip(path), batch_size)
    end

    # Converts headers from camelcase to snakecase
    def self.convert_header(str)
      return str.underscore.sub(' ', '_').remove('(', ')')
    end

    def self.read_data_csv_from_zip(path)
      Zip::File.open(path) do |zip|
        zip.each do |file|
          if file.name[..13] == 'edubasealldata'
            return file.get_input_stream.read.force_encoding(Encoding::ISO_8859_1)
          end
        end
        raise LoadError.new("Couldn't find file beginning with \"edubasealldata\" in #{path}")
      end
    end

    def self.import(csv_str, batch_size)
      rows = CSV.parse(csv_str, headers: true)
      headers = rows.first.headers

      # All headers from the CSV that match a database column when converted
      csv_headers = headers.filter { |h| Establishment.column_names.include?(convert_header(h)) }
      column_names = csv_headers.map { |h| convert_header(h) }
      # debug_print_map(csv_headers, column_names)

      # URN is the only header mapped to a column that isn't just the header in snakecase
      csv_headers.append('URN')
      column_names.append('id')

      batch_counter = 0
      batch = []
      rows.each do |row|
        batch.append(create_from_row(row, csv_headers, column_names))
        batch_counter += 1
        if batch_counter == batch_size
          upsert_batch(batch)
          batch_counter = 0
          batch = []
        end
      end
      upsert_batch(batch)
      puts 'Finished successfully'
    end

    def self.upsert_batch(batch)
      puts "Upserting batch of #{batch.length} entries"
      upsert_all(batch, unique_by: 'id')
    end

    def self.create_from_row(row, csv_headers, column_names)
      ret = {}
      (0..csv_headers.length - 1).each do |i|
        # Use model attributes to detect which type to cast to
        type = attribute_types[column_names[i]].class
        if type == ActiveModel::Type::Integer
          ret[column_names[i]] = row[csv_headers[i]].to_i
        elsif type == ActiveModel::Type::String
          ret[column_names[i]] = row[csv_headers[i]]
        elsif type == ActiveRecord::AttributeMethods::TimeZoneConversion::TimeZoneConverter
          ret[column_names[i]] = DateTime.parse(row[csv_headers[i]])
        end
      end
      return ret
    end
  end
end
