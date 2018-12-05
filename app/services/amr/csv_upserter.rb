require 'upsert'
require 'upsert/active_record_upsert'
require 'upsert/connection/postgresql'
require 'upsert/connection/PG_Connection'
require 'upsert/merge_function/PG_Connection'
require 'upsert/column_definition/postgresql'

module Amr
  class CsvUpserter
    attr_reader :inserted_record_count

    def initialize(config, array_of_rows, amr_data_feed_import_log_id)
      @config = config
      @array_of_rows = array_of_rows
      @map_of_fields_to_indexes = @config.map_of_fields_to_indexes
      @amr_data_feed_import_log_id = amr_data_feed_import_log_id
      @existing_records = AmrDataFeedReading.count
      @meter_id_hash = Meter.all.map { |m| [m.mpan_mprn.to_s, m.id]}.to_h
    end

    def perform
      @inserted_record_count = upsert_records(@array_of_rows)
    end

  private

    def upsert_records(array)
      Upsert.batch(AmrDataFeedReading.connection, AmrDataFeedReading.table_name) do |upsert|
        array.each { |row| upsert_record(upsert, row) }
      end
      AmrDataFeedReading.count - @existing_records
    end

    def upsert_record(upsert, row)
      readings =  readings_as_array(row)
      mpan_mprn = row[@config.mpan_mprn_index]
      reading_date_string = fetch_from_row(:reading_date_index, row)

      meter_id = @meter_id_hash[mpan_mprn]

      # This determines which row to select, values get updated for this particular row
      unique_record_selector = { mpan_mprn: mpan_mprn, reading_date: reading_date_string }

      upsert.row(unique_record_selector,
        amr_data_feed_config_id: @config.id,
        meter_id: meter_id,
        mpan_mprn: mpan_mprn,
        reading_date: reading_date_string,
        postcode: fetch_from_row(:postcode_index, row),
        units: fetch_from_row(:units_index, row),
        description: fetch_from_row(:description_index, row),
        meter_serial_number: fetch_from_row(:meter_serial_number_index, row),
        provider_record_id: fetch_from_row(:provider_record_id_index, row),
        readings: readings,
        amr_data_feed_import_log_id: @amr_data_feed_import_log_id,
        created_at: DateTime.now.utc,
        updated_at: DateTime.now.utc
      )
    end

    def fetch_from_row(index_symbol, row)
      return if @map_of_fields_to_indexes[index_symbol].nil?
      row[@map_of_fields_to_indexes[index_symbol]]
    end

    def readings_as_array(amr_data_feed_row)
      @config.array_of_reading_indexes.map { |reading_index| amr_data_feed_row[reading_index] }
    end
  end
end
