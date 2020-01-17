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
      array_of_rows
    end

  private

    def handle_header(array_of_rows)
      if array_of_rows.first.join(',') == @config.header_example
        array_of_rows[1, array_of_rows.length]
      elsif @config.number_of_header_rows
        array_of_rows[@config.number_of_header_rows, array_of_rows.length]
      else
        array_of_rows
      end
    end

    def sort_out_off_by_one_array(array_of_rows)
      new_array = []

      array_of_rows.each_cons(2).with_index do |(row, next_row), row_index|
        # row has 48 readings, but first is from the day before
        # remove that one
        new_row = row.reject.with_index { |_record, record_index| record_index == index_of_midnight_for_off_by_one }

        # Add that first one from the next day to the end of todays
        new_row << next_row[index_of_midnight_for_off_by_one]
        new_array << new_row
        new_array << next_row if row_index == array_of_rows.size - 2 # i.e. the very last one
      end

      new_array.last.slice!(index_of_midnight_for_off_by_one)
      new_array.last << "0.0"
      new_array
    end

    def index_of_midnight_for_off_by_one
      @index_of_midnight_for_off_by_one || @config.header_example.split(',').find_index(@config.reading_fields.first)
    end

    def invalid_row?(row)
      # Reject if row is empty or there are no commas to create fields
      row.empty? || row.count == 1
    end
  end
end
