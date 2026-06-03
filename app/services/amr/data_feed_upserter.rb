module Amr
  class DataFeedUpserter
    # This is used to specify the update clause for when we are merging into existing
    # data rather than just replacing.
    #
    # The clause needs to specify all columns that will be updated when a duplicate is
    # found during the upsert
    #
    # In a Postgres upsert statement the new data is referenced via a set called "excluded"
    # So the new readings to be inserted can be referenced as "excluded.readings"
    #
    # We define this update clause to provide logic that defines how to create the array of
    # updated readings to be stored in the database
    #
    # The query uses the set returning function generate_series to generate indexes
    # for the array (1..48). The single column returned by that set is aliased as i.
    #
    # The new array to be inserted is created using the array_agg function
    # and a CASE statement. The CASE statement essentially iterates over each array entry
    # to decide how to merge the values, returning one row per entry. The array_agg function
    # then turns those rows into a single array value.
    #
    # The logic in the CASE statement is that if we have missing entries in the data
    # to be inserted then we will merge that with the currently saved array. Otherwise
    # the new values overwrite anything already stored.
    #
    # This allows new data to override anything already in the system, but where we have
    # partial days, we end up with a merged array.
    #
    # Postgres has no built in functions to do this type of array merging. This approach also
    # avoids having to declare a custom function
    #
    # For all the other columns we just take the values from the incoming data.
    ON_DUPLICATE_UPDATE_CLAUSE = <<~SQL.squish
      readings = (
          SELECT array_agg(
            CASE
              WHEN (amr_data_feed_readings.readings)[s.i] IS NOT NULL AND (excluded.readings)[s.i] IS NULL
                   THEN (amr_data_feed_readings.readings)[s.i]
              ELSE (excluded.readings)[s.i]
            END)
          FROM generate_series(1, 48) AS s(i)
      ),
      amr_data_feed_config_id = excluded.amr_data_feed_config_id,
      meter_id = excluded.meter_id,
      amr_data_feed_import_log_id = excluded.amr_data_feed_import_log_id,
      created_at = excluded.created_at,
      updated_at = excluded.updated_at
    SQL

    def initialize(amr_data_feed_config, amr_data_feed_import_log, array_of_data_feed_reading_hashes)
      @amr_data_feed_config = amr_data_feed_config
      @array_of_data_feed_reading_hashes = array_of_data_feed_reading_hashes
      @amr_data_feed_import_log = amr_data_feed_import_log
    end

    def perform
      return log_changes(0, 0) if @array_of_data_feed_reading_hashes.empty?

      records_count_before = count_by_mpan

      add_import_log_id_and_dates_to_hash
      upserted_count = do_upsert

      inserted_count = count_by_mpan - records_count_before
      updated_count = upserted_count - inserted_count

      log_changes(inserted_count, updated_count)
    end

    private

    def do_upsert
      on_duplicate = @amr_data_feed_config.allow_merging ? Arel.sql(ON_DUPLICATE_UPDATE_CLAUSE) : :update
      @array_of_data_feed_reading_hashes.each_slice(100).sum do |batch|
        result = AmrDataFeedReading.upsert_all(batch, unique_by: %i[mpan_mprn reading_date], on_duplicate:)
        result.rows.flatten.size
      end
    end

    def log_changes(inserted, updated)
      @amr_data_feed_import_log.update(records_imported: inserted, records_updated: updated)
      Rails.logger.info "Updated #{updated} Inserted #{inserted}"
      @amr_data_feed_import_log
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
