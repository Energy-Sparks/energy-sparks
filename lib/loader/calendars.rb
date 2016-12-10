require 'csv'

module Loader
  class Calendars
    # load default calendar from csv
    def self.load!(csv_file)
      raise 'File not found' unless File.exist?(csv_file)
      default_calendar = Calendar.default_calendar
      CSV.foreach(csv_file, headers: true) do |row|
        start_date = Date.parse(row["Start Date"])
        end_date = Date.parse(row["End Date"])
        default_calendar.terms.create( name: row["Term"], start_date: row["Start Date"], end_date: row["End Date"])
      end
    end
  end
end
