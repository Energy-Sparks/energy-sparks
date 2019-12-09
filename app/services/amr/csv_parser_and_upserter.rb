module Amr
  class CsvParserAndUpserter
    attr_reader :inserted_record_count, :upserted_record_count

    def initialize(config_to_parse_file, file_name_to_import)
      @file_name = file_name_to_import
      @config = config_to_parse_file
    end

    def perform
      Rails.logger.info "Loading: #{@config.local_bucket_path}/#{@file_name}"
      records_before = AmrDataFeedReading.count

      amr_data_feed_import_log = AmrDataFeedImportLog.create(amr_data_feed_config_id: @config.id, file_name: @file_name, import_time: DateTime.now.utc)

      @upserted_record_count = DataFeedUpserter.new(get_unique_array_of_readings, amr_data_feed_import_log.id).perform
      @inserted_record_count = AmrDataFeedReading.count - records_before

      Rails.logger.info "Loaded: #{@config.local_bucket_path}/#{@file_name} records inserted: #{@inserted_record_count} records upserted: #{@upserted_record_count}"

      amr_data_feed_import_log.update(records_imported: @inserted_record_count, records_upserted: @upserted_record_count)
      amr_data_feed_import_log
    end

    private

    def get_unique_array_of_readings
      array_of_rows = CsvParser.new(@config, @file_name).perform
      array_of_rows = DataFeedValidator.new(@config, array_of_rows).perform
      array_of_data_feed_reading_hashes = DataFeedTranslator.new(@config, array_of_rows).perform

      array_of_data_feed_reading_hashes = SingleReadConverter.new(array_of_data_feed_reading_hashes).perform if @config.row_per_reading
      array_of_data_feed_reading_hashes.uniq
    end
  end
end
