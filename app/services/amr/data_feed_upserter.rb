module Amr
  class DataFeedUpserter
    attr_reader :inserted_record_count, :upserted_record_count

    def initialize(array_of_data_feed_reading_hashes, amr_data_feed_import_log_id)
      @array_of_data_feed_reading_hashes = array_of_data_feed_reading_hashes
      @amr_data_feed_import_log_id = amr_data_feed_import_log_id
    end

    def perform
      add_import_log_id_and_dates_to_hash
      result = AmrDataFeedReading.upsert_all(@array_of_data_feed_reading_hashes, unique_by: [:mpan_mprn, :reading_date])
      result.rows.flatten.size
    end

  private

    def add_import_log_id_and_dates_to_hash
      created_at = DateTime.now.utc
      updated_at = DateTime.now.utc
      @array_of_data_feed_reading_hashes.each do |reading|
        reading[:amr_data_feed_import_log_id] = @amr_data_feed_import_log_id
        reading[:created_at] = created_at
        reading[:updated_at] = updated_at
      end
    end
  end
end
