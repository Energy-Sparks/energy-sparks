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

      ProcessAmrReadingData.new(amr_reading_data, amr_data_feed_import_log).perform

      @inserted_record_count = amr_data_feed_import_log.records_imported
      @upserted_record_count = amr_data_feed_import_log.records_upserted

      Rails.logger.info "Loaded: #{@config.local_bucket_path}/#{@file_name} records inserted: #{@inserted_record_count} records upserted: #{@upserted_record_count}"

      amr_data_feed_import_log
    end
  end
end
