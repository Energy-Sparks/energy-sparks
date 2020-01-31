require 'csv'

module Amr
  class CsvParser
    class Error < StandardError; end

    def initialize(config, path_and_file_name)
      @path_and_file_name = path_and_file_name
      @config = config
    end

    def perform
      CSV.read(@path_and_file_name, col_sep: @config.column_separator, row_sep: :auto)
    rescue CSV::MalformedCSVError => e
      raise Error, e.message
    end
  end
end
