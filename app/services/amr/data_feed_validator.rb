module Amr
  class DataFeedValidator
    def initialize(config, array_of_rows)
      @config = config
      @array_of_rows = array_of_rows
    end

    def perform
      array_of_rows = handle_header(@array_of_rows)
      array_of_rows = sort_out_off_by_one_array(array_of_rows) if @config.handle_off_by_one && array_of_rows.size > 1
      array_of_rows = array_of_rows.reject { |row| invalid_row?(row) }
      array_of_rows = array_of_rows.reject { |row| partial_row?(row) } if should_reject_rows?
      array_of_rows = filter_column_rows_for(array_of_rows) if @config.column_row_filters.present? && headers_as_array
      array_of_rows
    end

  private

    def filter_column_rows_for(array_of_rows)
      @config.column_row_filters.each do |column_name, filter_as_regex|
        column_index = headers_as_array.index(column_name)
        next unless column_index
        # if there's no value for the column we're trying to filter it's an incomplete row,
        # e.g. has fewer columns than expected so remove
        array_of_rows = array_of_rows.reject { |row| row[column_index].nil? || row[column_index].match?(filter_as_regex) }
      end
      array_of_rows
    end

    def headers_as_array
      @headers_as_array ||= @config&.header_example&.split(',')
    end

    def handle_header(array_of_rows)
      if array_of_rows.empty?
        array_of_rows
      elsif array_of_rows.first.join(',') == @config.header_example
        array_of_rows[1, array_of_rows.length]
      elsif @config.number_of_header_rows
        if @config.number_of_header_rows > array_of_rows.length
          raise DataFeedException.new("Expected #{@config.number_of_header_rows} header rows but file has only #{array_of_rows.length}.")
        else
          array_of_rows[@config.number_of_header_rows, array_of_rows.length]
        end
      else
        array_of_rows
      end
    end

    def sort_out_off_by_one_array(array_of_rows)
      new_array = []

      array_of_rows.each_cons(2).with_index do |(row, next_row), row_index|
        # row has 48 readings, but first is from the day before
        # remove that one
        new_row = row.reject.with_index { |_record, record_index| record_index == index_of_first_reading_field }

        # Add that first one from the next day to the end of todays
        new_row << next_row[index_of_first_reading_field]
        new_array << new_row
        new_array << next_row if row_index == array_of_rows.size - 2 # i.e. the very last one
      end

      new_array.last.slice!(index_of_first_reading_field)
      new_array.last << '0.0'
      new_array
    end

    def index_of_first_reading_field
      @index_of_first_reading_field ||= @config.header_example.split(',').find_index(@config.reading_fields.first)
    end

    def index_of_last_reading_field
      @index_of_last_reading_field ||= @config.header_example.split(',').find_index(@config.reading_fields.last)
    end

    def invalid_row?(row)
      # Reject if row is empty or there are no commas to create fields
      row.empty? || row.count == 1
    end

    def partial_row?(row)
      # Reject if row has more than the allowed number of missing readings
      return true unless row.count > index_of_last_reading_field
      row[index_of_first_reading_field..index_of_last_reading_field].count(&:blank?) > @config.missing_readings_limit
    end

    # Don't apply the missing_readings_limit to reject partial rows for row_per_reading format
    # That is done in SingleReadConverter for those configs
    def should_reject_rows?
      return false if @config.row_per_reading?
      @config.missing_readings_limit.present?
    end
  end
end
