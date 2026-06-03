require 'csv'
require 'roo'
require 'roo-xls'

module Amr
  class DataFileParser
    class Error < StandardError; end

    attr_reader :path_and_file_name, :config

    ILLEGAL_QUOTING = 'Illegal quoting in line 1.'.freeze

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
          clean_csv_data(path_and_file_name)
        end
      CSV.parse(content, col_sep: @config.column_separator, row_sep: :auto)
    rescue CSV::MalformedCSVError, Roo::Error => e
      if ignorable_error?(e.message)
        return []
      else
        raise Error, e.message
      end
    end

    private

    def ignorable_error?(error)
      return config.identifier == 'energy-assets2' && error == ILLEGAL_QUOTING
    end

    def clean_csv_data(path_and_file_name)
      data = StringIO.new
      File.readlines(path_and_file_name).each do |line|
        line = remove_utf8_invalids(line)
        line = remove_utf8_nulls(line)
        data.puts line.encode('UTF-8', universal_newline: true)
      end
      data.string
    end

    def remove_utf8_invalids(line)
      line.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
    end

    def remove_utf8_nulls(line)
      line.delete("\u0000")
    end
  end
end
