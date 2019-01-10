require 'upsert'
require 'upsert/active_record_upsert'
require 'upsert/connection/postgresql'
require 'upsert/connection/PG_Connection'
require 'upsert/merge_function/PG_Connection'
require 'upsert/column_definition/postgresql'

module Amr
  class DataFeedUpserter
    attr_reader :inserted_record_count

    def initialize(array_of_data_feed_reading_hashes, amr_data_feed_import_log_id)
      @array_of_data_feed_reading_hashes = array_of_data_feed_reading_hashes
      @amr_data_feed_import_log_id = amr_data_feed_import_log_id
    end

    def perform
      @inserted_record_count = upsert_records(@array_of_data_feed_reading_hashes)
    end

  private

    def upsert_records(array_of_data_feed_reading_hashes)
      @existing_records = AmrDataFeedReading.count
      Upsert.batch(AmrDataFeedReading.connection, AmrDataFeedReading.table_name) do |upsert|
        array_of_data_feed_reading_hashes.each { |row| upsert_record(upsert, row) }
      end
      AmrDataFeedReading.count - @existing_records
    end

    def upsert_record(upsert, data_feed_reading_hash)
      # This determines which row to select, values get updated for this particular row
      unique_record_selector = { mpan_mprn: data_feed_reading_hash[:mpan_mprn], reading_date: data_feed_reading_hash[:reading_date] }

      upsert.row(unique_record_selector,
        amr_data_feed_config_id: data_feed_reading_hash[:amr_data_feed_config_id],
        meter_id: data_feed_reading_hash[:meter_id],
        mpan_mprn: data_feed_reading_hash[:mpan_mprn],
        reading_date: data_feed_reading_hash[:reading_date],
        postcode: data_feed_reading_hash[:postcode],
        units: data_feed_reading_hash[:units],
        description: data_feed_reading_hash[:description],
        meter_serial_number: data_feed_reading_hash[:meter_serial_number],
        provider_record_id: data_feed_reading_hash[:provider_record_id],
        readings: data_feed_reading_hash[:readings],
        amr_data_feed_import_log_id: @amr_data_feed_import_log_id,
        created_at: DateTime.now.utc,
        updated_at: DateTime.now.utc
      )
    end
  end
end
