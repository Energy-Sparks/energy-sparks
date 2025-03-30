module Amr
  class DataFileToAmrReadingData
    def initialize(config_to_parse_file, path_and_file_name)
      @config = config_to_parse_file
      @path_and_file_name = path_and_file_name
    end

    def perform
      array_of_rows = DataFileParser.new(@config, @path_and_file_name).perform
      array_of_rows = DataFeedValidator.new(@config, array_of_rows).perform
      array_of_data_feed_reading_hashes = DataFeedTranslator.new(@config, array_of_rows).perform

      array_of_data_feed_reading_hashes = convert_to_day_per_row_format(array_of_data_feed_reading_hashes) if @config.row_per_reading
      array_of_data_feed_reading_hashes.uniq

      AmrReadingData.new(amr_data_feed_config: @config, reading_data: array_of_data_feed_reading_hashes.uniq)
    end

    private

    def convert_to_day_per_row_format(array_of_data_feed_reading_hashes)
      SingleReadConverter.new(@config, array_of_data_feed_reading_hashes).perform
    rescue ArgumentError
      {}
    end
  end
end
