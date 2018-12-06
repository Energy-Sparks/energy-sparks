require 'csv'

module Amr
  class CsvParser
    def initialize(config, file_name)
      @file_name = file_name
      @config = config
    end

    def perform
      CSV.read("#{@config.local_bucket_path}/#{@file_name}", col_sep: @config.column_separator, row_sep: :auto)
    end
  end
end
