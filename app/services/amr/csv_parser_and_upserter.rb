module Amr
  class CsvParserAndUpserter
    def self.perform(config, file_path, import_log_file_name)
      Rails.logger.info "Loading: #{file_path}"
      import_log = AmrDataFeedImportLog.create(
        amr_data_feed_config_id: config.id, file_name: import_log_file_name, import_time: DateTime.now.utc
      )
      begin
        amr_reading_data = DataFileToAmrReadingData.new(config, file_path).perform
        if amr_reading_data.valid?
          ProcessAmrReadingData.new(config, import_log).perform(amr_reading_data.valid_records,
                                                                amr_reading_data.warnings)
        else
          import_log.update(error_messages: amr_reading_data.error_messages_joined, records_imported: 0,
                            records_updated: 0)
        end
      rescue DataFeedException => e
        # ensure that unexpected validation errors are recorded in the import log
        import_log.update(error_messages: e.message, records_imported: 0, records_updated: 0)
        Rollbar.error(e, job: :import_all, config: config.identifier)
      end
      Rails.logger.info "Loaded: #{file_path} records inserted: #{import_log.records_imported} " \
                        "records updated: #{import_log.records_updated}"
      import_log
    end
  end
end
