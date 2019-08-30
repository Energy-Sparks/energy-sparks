module Amr
  class CsvParserAndUpserter
    attr_reader :inserted_record_count

    def initialize(config_to_parse_file, file_name_to_import)
      @file_name = file_name_to_import
      @config = config_to_parse_file
    end

    def perform
      Rails.logger.info "Loading: #{@config.local_bucket_path}/#{@file_name}"
      amr_data_feed_import_log = AmrDataFeedImportLog.create(amr_data_feed_config_id: @config.id, file_name: @file_name, import_time: DateTime.now.utc)

      array_of_rows = CsvParser.new(@config, @file_name).perform
      array_of_rows = DataFeedValidator.new(@config, array_of_rows).perform
      array_of_data_feed_reading_hashes = DataFeedTranslator.new(@config, array_of_rows).perform

      array_of_data_feed_reading_hashes = SingleReadConverter.new(array_of_data_feed_reading_hashes).perform if @config.row_per_reading
      @inserted_record_count = row_per_day(array_of_data_feed_reading_hashes, amr_data_feed_import_log)

      # @inserted_record_count = if @config.row_per_reading
      #                            row_per_reading(array_of_data_feed_reading_hashes, amr_data_feed_import_log)
      #                          else
      #                            row_per_day(array_of_data_feed_reading_hashes, amr_data_feed_import_log)
      #                          end

      Rails.logger.info "Loaded: #{@config.local_bucket_path}/#{@file_name} records inserted: #{@inserted_record_count}"
      amr_data_feed_import_log.update(records_imported: @inserted_record_count)
      @inserted_record_count
    end

    private

    def row_per_day(array_of_data_feed_reading_hashes, amr_data_feed_import_log)
      DataFeedUpserter.new(array_of_data_feed_reading_hashes, amr_data_feed_import_log.id).perform
    end

    def row_per_reading(array_of_data_feed_reading_hashes, amr_data_feed_import_log)
      populate_single_readings(array_of_data_feed_reading_hashes, amr_data_feed_import_log)

      query = <<-SQL
        SELECT date_trunc('day', reading_date_time) AS day, mpan_mprn, array_agg(reading ORDER BY reading_date_time ASC) AS values
        FROM amr_single_readings
        GROUP BY date_trunc('day', reading_date_time), mpan_mprn
        ORDER BY day ASC
      SQL

      result = ActiveRecord::Base.connection.execute(query)
      result.each do |row|
         AmrDataFeedReading.upsert_all([{
          amr_data_feed_config_id: @config.id,
          mpan_mprn: row["mpan_mprn"],
          reading_date: row["day"],
          readings: row["values"].delete('{}').split(',').map(&:to_f),
          amr_data_feed_import_log_id: amr_data_feed_import_log.id,
          created_at: DateTime.now.utc,
          updated_at: DateTime.now.utc
        }], unique_by: [:mpan_mprn, :reading_date])
      end
    end

    def populate_single_readings(array_of_data_feed_reading_hashes, amr_data_feed_import_log)
      puts array_of_data_feed_reading_hashes

      array_of_data_feed_reading_hashes.each do |data_feed_reading_hash|
        AmrSingleReading.upsert_all([{
              amr_data_feed_config_id: @config.id,
              amr_data_feed_import_log_id: amr_data_feed_import_log.id,
              meter_id: data_feed_reading_hash[:meter_id],
              mpan_mprn: data_feed_reading_hash[:mpan_mprn],
              reading: data_feed_reading_hash[:readings].first,
              reading_date_time: DateTime.parse(data_feed_reading_hash[:reading_date]),
              reading_date_time_as_text: data_feed_reading_hash[:reading_date],
              reading_type: AmrSingleReading.reading_types[:actual],
              created_at: Time.now.utc,
              updated_at: Time.now.utc
          }], unique_by: [:mpan_mprn, :reading_date_time_as_text])
      end
    end
  end
end
