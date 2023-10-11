module Amr
  class DataFeedUpserter
    def initialize(array_of_data_feed_reading_hashes, amr_data_feed_import_log)
      @array_of_data_feed_reading_hashes = array_of_data_feed_reading_hashes
      @amr_data_feed_import_log = amr_data_feed_import_log
    end

    def perform
      records_count_before = count_by_mpan

      add_import_log_id_and_dates_to_hash
      result = AmrDataFeedReading.upsert_all(@array_of_data_feed_reading_hashes, unique_by: %i[mpan_mprn reading_date])

      inserted_count = count_by_mpan - records_count_before
      updated_count = result.rows.flatten.size - inserted_count

      @amr_data_feed_import_log.update(records_imported: inserted_count, records_updated: updated_count)

      Rails.logger.info "Updated #{updated_count} Inserted #{inserted_count}"
    end

    private

    def count_by_mpan
      mpans = []
      @array_of_data_feed_reading_hashes.each do |hash|
        mpans << hash[:mpan_mprn]
      end
      AmrDataFeedReading.where(mpan_mprn: mpans.uniq).count
    end

    def add_import_log_id_and_dates_to_hash
      created_at = DateTime.now.utc
      updated_at = DateTime.now.utc
      @array_of_data_feed_reading_hashes.each do |reading|
        reading[:amr_data_feed_import_log_id] = @amr_data_feed_import_log.id
        reading[:created_at] = created_at
        reading[:updated_at] = updated_at
      end
    end
  end
end
