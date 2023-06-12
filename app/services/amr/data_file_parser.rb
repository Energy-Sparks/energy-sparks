require 'csv'
require 'roo'
require 'roo-xls'

module Amr
  class DataFileParser
    class Error < StandardError; end

    attr_reader :path_and_file_name, :config

    def initialize(config, path_and_file_name)
      @path_and_file_name = path_and_file_name
      @config = config
    end

    def perform
      ext = File.extname(path_and_file_name)

      content =
        if %w(.xlsx .xls).include?(ext)
          spreadsheet = Roo::Spreadsheet.open(path_and_file_name)
          spreadsheet.sheet(0).to_csv
        else
          File.read(path_and_file_name)
        end
      CSV.parse(content, col_sep: config.column_separator, row_sep: :auto)
    rescue CSV::MalformedCSVError, Roo::Error => e
      raise Error, e.message
    end
  end
end
