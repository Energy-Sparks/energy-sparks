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

      @inserted_record_count = if @config.row_per_reading
                                 row_per_reading(array_of_data_feed_reading_hashes, amr_data_feed_import_log)
                               else
                                 row_per_day(array_of_data_feed_reading_hashes, amr_data_feed_import_log)
                               end

      Rails.logger.info "Loaded: #{@config.local_bucket_path}/#{@file_name} records inserted: #{@inserted_record_count}"
      amr_data_feed_import_log.update(records_imported: @inserted_record_count)
      @inserted_record_count
    end

    private

    def row_per_day(array_of_data_feed_reading_hashes, amr_data_feed_import_log)
      DataFeedUpserter.new(array_of_data_feed_reading_hashes, amr_data_feed_import_log.id).perform
    end

    def row_per_reading(array_of_data_feed_reading_hashes, amr_data_feed_import_log)
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

#     def row_per_reading(array_of_data_feed_reading_hashes, amr_data_feed_import_log)

#       array_of_data_feed_reading_hashes.each do |data_feed_reading_hash|

#         reading_day = Date.parse(data_feed_reading_hash[:reading_date])
#         reading_day_time = Time.parse(data_feed_reading_hash[:reading_date])
#         first_reading_time = reading_day.to_time + 30.minutes

#         reading_index = ((reading_day_time - first_reading_time) / 30.minutes).to_i

#         data_feed_reading_hash[:date] = reading_day
#         data_feed_reading_hash[:reading_index] = reading_index
#       end


#       puts array_of_data_feed_reading_hashes.first
#       puts array_of_data_feed_reading_hashes.second
#       puts array_of_data_feed_reading_hashes.third

# #     {:amr_data_feed_config_id=>36, :meter_id=>nil, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 00:30:00", :postcode=>nil, :units=>nil, :description=>nil, :meter_serial_number=>nil, :provider_record_id=>nil, :readings=>["14.4"]}
# #     {:amr_data_feed_config_id=>36, :meter_id=>nil, :mpan_mprn=>"1710035168313", :reading_date=>"26 Aug 2019 01:00:00", :postcode=>nil, :units=>nil, :description=>nil, :meter_serial_number=>nil, :provider_record_id=>nil, :readings=>["15"]}

#     end
