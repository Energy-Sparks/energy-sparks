module Amr
  class DataFeedTranslator
    def initialize(config, array_of_rows)
      @config = config
      @array_of_rows = array_of_rows
      @meters_by_mpan_mprn = {}
      @meters_by_serial_number = {}
    end

    def perform
      hash_rows = @array_of_rows.map { |row| translate_row_to_hash(row) }
      check_units(hash_rows)
    end

  private

    def translate_row_to_hash(row)
      data_feed_reading_hash = meter_details_from_row(row)
      data_feed_reading_hash[:amr_data_feed_config_id] = @config.id
      data_feed_reading_hash[:reading_date] = reading_date(row)
      data_feed_reading_hash[:reading_time] = fetch_from_row(:reading_time_index, row)
      data_feed_reading_hash[:postcode] = fetch_from_row(:postcode_index, row)
      data_feed_reading_hash[:units] = fetch_from_row(:units_index, row)
      data_feed_reading_hash[:description] = fetch_from_row(:description_index, row)
      data_feed_reading_hash[:provider_record_id] = fetch_from_row(:provider_record_id_index, row)
      data_feed_reading_hash[:readings] = readings_as_array(data_feed_reading_hash, row)
      data_feed_reading_hash[:period] = fetch_from_row(:period_index, row) if @config.positional_index
      data_feed_reading_hash
    end

    def meter_details_from_row(row)
      if @config.lookup_by_serial_number
        meter_serial_number = fetch_from_row(:meter_serial_number_index, row)&.strip
        meter = find_meter_by_serial_number(meter_serial_number)
        mpan_mprn = meter ? meter.mpan_mprn.to_s : nil
      else
        mpan_mprn = fetch_from_row(:mpan_mprn_index, row)&.strip
        meter = find_meter_by_mpan_mprn(mpan_mprn)
        meter_serial_number = meter ? meter.meter_serial_number.to_s : nil
      end
      {
        meter_id: meter ? meter.id : nil,
        meter_serial_number: meter_serial_number,
        mpan_mprn: mpan_mprn
      }
    end

    def reading_date(row)
      date_string = fetch_from_row(:reading_date_index, row)
      return date_string unless @config.delayed_reading

      # a delayed reading config means the date/date-time column is when the readings
      # where collected, rather than the date the energy was consumed. For now
      # this only appears in one config where the readings are collected a day later
      begin
        date = DateTime.strptime(date_string, @config.date_format)
        date = date - 1.day
        date.strftime(@config.date_format)
      rescue ArgumentError
        # return nil here and we should end up rejecting the data
        # better to do this than load with incorrect date
        nil
      end
    end

    def fetch_from_row(index_symbol, row)
      return if map_of_fields_to_indexes[index_symbol].nil?
      row[map_of_fields_to_indexes[index_symbol]]
    end

    def readings_as_array(data_feed_reading_hash, amr_data_feed_row)
      array_of_readings = @config.array_of_reading_indexes.map { |reading_index| amr_data_feed_row[reading_index] }
      return array_of_readings if array_of_readings.all?(&:blank?) || !@config.convert_to_kwh

      # if no units specified for each row, assume m3 and convert
      # if units are specified, then only convert if they are m3
      if data_feed_reading_hash[:units].blank? || data_feed_reading_hash[:units].casecmp?('m3')
        data_feed_reading_hash[:units] = 'kwh'
        array_of_readings.map { |r| r.to_f * Amr::N3rgyDownloader::KWH_PER_M3_GAS }
      else
        array_of_readings
      end
    end

    # Applies a filter to the translated rows, excluding those that dont match the expected units
    def check_units(rows)
      return rows if @config.expected_units.blank?
      rows.select {|row| row[:units] == @config.expected_units}
    end

    def find_meter_by_mpan_mprn(mpan_mprn)
      unless @meters_by_mpan_mprn.key?(mpan_mprn)
        meters = Meter.where(mpan_mprn: mpan_mprn)
        raise DataFeedException.new("Multiple meters found with mpan_mprn #{mpan_mprn}") if meters.size > 1
        @meters_by_mpan_mprn[mpan_mprn] = meters.first
      end
      @meters_by_mpan_mprn[mpan_mprn]
    end

    def find_meter_by_serial_number(meter_serial_number)
      unless @meters_by_serial_number.key?(meter_serial_number)
        meters = Meter.where(meter_serial_number: meter_serial_number)
        raise DataFeedException.new("Multiple meters found with meter_serial_number #{meter_serial_number}") if meters.size > 1
        @meters_by_serial_number[meter_serial_number] = meters.first
      end
      @meters_by_serial_number[meter_serial_number]
    end

    def map_of_fields_to_indexes
      @map_of_fields_to_indexes ||= @config.map_of_fields_to_indexes
    end
  end
end
