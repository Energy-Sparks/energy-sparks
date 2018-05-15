require 'csv'

module Loader
  class Calendars
    # load default calendar from csv
    def self.load!(csv_file = 'etc/banes-default-calendar.csv')
      raise 'File not found' unless File.exist?(csv_file)
      england = Area.where(title: 'England and Wales').first_or_create
      pp england
      area = Area.where(title: 'Bristol and North East Somerset (BANES)', parent_area: england).first_or_create
      pp area
      calendar = Calendar.where(default: true, area: area, title: area.title).first_or_create
      pp calendar.errors
      CSV.foreach(csv_file, headers: true) do |row|
        calendar.calendar_events.create(title: row["Term"], start_date: row["Start Date"], end_date: row["End Date"])
      end
    end
  end
end
