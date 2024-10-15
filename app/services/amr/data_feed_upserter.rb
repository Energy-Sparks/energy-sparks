module Amr
  class DataFeedUpserter
    def initialize(amr_data_feed_config, amr_data_feed_import_log, array_of_data_feed_reading_hashes)
      @amr_data_feed_config = amr_data_feed_config
      @array_of_data_feed_reading_hashes = array_of_data_feed_reading_hashes
      @amr_data_feed_import_log = amr_data_feed_import_log
    end

    def perform
      log_changes(0, 0) and return if @array_of_data_feed_reading_hashes.empty?

      records_count_before = count_by_mpan

      add_import_log_id_and_dates_to_hash
      result = AmrDataFeedReading.upsert_all(@array_of_data_feed_reading_hashes, unique_by: [:mpan_mprn, :reading_date])

      inserted_count = count_by_mpan - records_count_before
      updated_count = result.rows.flatten.size - inserted_count

      log_changes(inserted_count, updated_count)
    end

  private

    def log_changes(inserted, updated)
      @amr_data_feed_import_log.update(records_imported: inserted, records_updated: updated)
      Rails.logger.info "Updated #{updated} Inserted #{inserted}"
    end

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
