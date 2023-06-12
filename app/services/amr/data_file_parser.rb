require 'csv'

module Amr
  class DataFileParser
    class Error < StandardError; end

    attr_reader :path_and_file_name, :config

    def initialize(config, path_and_file_name)
      @path_and_file_name = path_and_file_name
      @config = config
    end

    def perform
      spreadsheet = Roo::Spreadsheet.open(path_and_file_name)
      content = spreadsheet.sheet(0).to_csv
      CSV.parse(content, col_sep: config.column_separator, row_sep: :auto)
    rescue CSV::MalformedCSVError, Roo::Error => e
      raise Error, e.message
    end
  end
end
