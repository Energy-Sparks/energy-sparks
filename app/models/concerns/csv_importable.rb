module CsvImportable
  extend ActiveSupport::Concern

  # rubocop:disable Metrics/BlockLength
  class_methods do
    def csv_name_starts_with
      ''
    end

    def csv_special_columns
      []
    end

    def upsert_batch(batch)
      puts "Upserting batch of #{batch.length} entries to table"
      upsert_all(batch)
    end

    def create_from_row(row, headers_to_attributes)
      headers_to_attributes.to_h do |header, attr_name|
        [attr_name, attribute_types[attr_name].cast(row[header])]
      end
    end

    def import(csv_str, batch_size)
      rows = CSV.parse(csv_str, headers: true)

      # Array of pairs mapping headers from the CSV that match a database column when converted
      headers_to_attributes = rows.first.headers.filter_map do |h|
        [h, convert_header(h)] if column_names.include?(convert_header(h))
      end
      headers_to_attributes = headers_to_attributes.nil? ? csv_special_columns : headers_to_attributes.union(csv_special_columns)

      rows.map { |row| create_from_row(row, headers_to_attributes) }.each_slice(batch_size) { |batch| upsert_batch(batch) }

      puts 'Finished successfully'
    end

    # edubasealldata or links_edubasealldata
    def read_csv_from_zip(path)
      Zip::File.open(path) do |zip|
        zip.each do |file|
          if file.name.start_with?(csv_name_starts_with)
            return file.get_input_stream.read.force_encoding(Encoding::ISO_8859_1)
          end
        end
        raise LoadError.new("Couldn't find file beginning with \"#{csv_name_starts_with}\" in #{path}")
      end
    end

    def import_from_zip(path, batch_size)
      import(read_csv_from_zip(path), batch_size)
    end

    # Converts headers from camelcase to snakecase
    def convert_header(str)
      str.underscore.sub(' ', '_').remove('(', ')')
    end
  end
  # rubocop:enable Metrics/BlockLength
end
