module Amr
  class DataFeedTranslator
    def initialize(config, array_of_rows)
      @config = config
      @array_of_rows = array_of_rows
    end

    def perform
      @map_of_fields_to_indexes = @config.map_of_fields_to_indexes
      @meter_id_hash = Meter.all.map { |m| [m.mpan_mprn.to_s, m.id]}.to_h
      hash_rows = @array_of_rows.map { |row| translate_row_to_hash(row) }
      check_units(hash_rows)
    end

  private

    def translate_row_to_hash(row)
      mpan_mprn = fetch_from_row(:mpan_mprn_index, row)
      meter_id = @meter_id_hash[mpan_mprn]

      reading_date_string = fetch_from_row(:reading_date_index, row)

      data_feed_reading_hash = {}

      data_feed_reading_hash[:amr_data_feed_config_id] = @config.id
      data_feed_reading_hash[:meter_id] = meter_id
      data_feed_reading_hash[:mpan_mprn] = mpan_mprn
      data_feed_reading_hash[:reading_date] = reading_date_string
      data_feed_reading_hash[:postcode] = fetch_from_row(:postcode_index, row)
      data_feed_reading_hash[:units] = fetch_from_row(:units_index, row)
      data_feed_reading_hash[:description] = fetch_from_row(:description_index, row)
      data_feed_reading_hash[:meter_serial_number] = fetch_from_row(:meter_serial_number_index, row)
      data_feed_reading_hash[:provider_record_id] = fetch_from_row(:provider_record_id_index, row)
      data_feed_reading_hash[:readings] = readings_as_array(row)
      data_feed_reading_hash
    end

    def fetch_from_row(index_symbol, row)
      return if @map_of_fields_to_indexes[index_symbol].nil?
      row[@map_of_fields_to_indexes[index_symbol]]
    end

    def readings_as_array(amr_data_feed_row)
      @config.array_of_reading_indexes.map { |reading_index| amr_data_feed_row[reading_index] }
    end

    def check_units(rows)
      return rows if @config.expected_units.blank?
      rows.select {|row| row[:units] == @config.expected_units}
    end
  end
end
