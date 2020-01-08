module Amr
  class CsvToAmrReadingData
    def initialize(config_to_parse_file, path_and_file_name)
      @path_and_file_name = path_and_file_name
      @config = config_to_parse_file
    end

    def perform
      array_of_rows = CsvParser.new(@config, @path_and_file_name).perform
      array_of_rows = DataFeedValidator.new(@config, array_of_rows).perform
      array_of_data_feed_reading_hashes = DataFeedTranslator.new(@config, array_of_rows).perform

      array_of_data_feed_reading_hashes = SingleReadConverter.new(array_of_data_feed_reading_hashes).perform if @config.row_per_reading
      array_of_data_feed_reading_hashes.uniq

      missing_reading_threshold = @config.row_per_reading? ? SingleReadConverter::BLANK_THRESHOLD : 0

      AmrReadingData.new(reading_data: array_of_data_feed_reading_hashes.uniq, date_format: @config.date_format, missing_reading_threshold: missing_reading_threshold)
    end
  end
end
