module Amr
  class ProcessAmrReadingData
    def initialize(amr_reading_data, amr_data_feed_import_log)
      @amr_reading_data = amr_reading_data
      @amr_data_feed_import_log = amr_data_feed_import_log
    end

    def perform
      if @amr_reading_data.valid?
        DataFeedUpserter.new(@amr_reading_data.valid_records, @amr_data_feed_import_log).perform
      else
        @amr_data_feed_import_log.update(error_messages: @amr_reading_data.error_messages_joined, records_imported: 0, records_updated: 0)
      end

      create_warnings if @amr_reading_data.warnings?

      @amr_data_feed_import_log
    end

    private

    def create_warnings
      updated_warnings = @amr_reading_data.warnings.map do |warning|
        {
          amr_data_feed_import_log_id: @amr_data_feed_import_log.id,
          warning_types: warning[:warnings].map { |warning_symbol| AmrReadingWarning::WARNINGS.key(warning_symbol) },
          created_at: DateTime.now.utc,
          updated_at: DateTime.now.utc,
          mpan_mprn: warning[:mpan_mprn],
          reading_date: warning[:reading_date],
          readings: warning[:readings]
         }
      end
      AmrReadingWarning.insert_all(updated_warnings)
    end
  end
end
