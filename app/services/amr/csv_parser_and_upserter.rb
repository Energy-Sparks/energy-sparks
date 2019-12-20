module Amr
  class CsvParserAndUpserter
    attr_reader :inserted_record_count, :upserted_record_count

    def initialize(config_to_parse_file, file_name_to_import)
      @file_name = file_name_to_import
      @config = config_to_parse_file
      @inserted_record_count = 0
      @upserted_record_count = 0
    end

    def perform
      Rails.logger.info "Loading: #{@config.local_bucket_path}/#{@file_name}"
      amr_data_feed_import_log = AmrDataFeedImportLog.create(amr_data_feed_config_id: @config.id, file_name: @file_name, import_time: DateTime.now.utc)

      amr_reading_data = CsvToAmrReadingData.new(@config, "#{@config.local_bucket_path}/#{@file_name}").perform

      if amr_reading_data.valid?
        insert_valid_data(amr_reading_data.reading_data, amr_data_feed_import_log)
      else
        amr_data_feed_import_log.update(error_messages: amr_reading_data.error_messages_joined)
      end

      amr_data_feed_import_log
    end

    private

    def insert_valid_data(reading_data, amr_data_feed_import_log)
      records_before = AmrDataFeedReading.count
      @upserted_record_count = DataFeedUpserter.new(reading_data, amr_data_feed_import_log.id).perform
      @inserted_record_count = AmrDataFeedReading.count - records_before

      Rails.logger.info "Loaded: #{@config.local_bucket_path}/#{@file_name} records inserted: #{@inserted_record_count} records upserted: #{@upserted_record_count}"

      amr_data_feed_import_log.update(records_imported: @inserted_record_count, records_upserted: @upserted_record_count)
    end
  end
end
