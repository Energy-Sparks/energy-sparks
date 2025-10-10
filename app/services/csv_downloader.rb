# frozen_string_literal: true

module CsvDownloader
  def self.readings_to_csv(sql_query, csv_header)
    conn = ActiveRecord::Base.connection.raw_connection

    StringIO.open do |s|
      s.puts csv_header
      conn.copy_data "COPY (#{sql_query}) TO STDOUT WITH CSV;" do
        while (row = conn.get_copy_data)
          s.puts row.tr('"', '').tr('{', '').tr('}', '').chomp.to_s
        end
      end
      s.string
    end
  end
end
