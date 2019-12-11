module Amr
  class CsvToReadingsHash
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
    end
  end
end
