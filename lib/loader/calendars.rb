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
      calendar = Calendar.where(default: true, area: area, title: area.title, template: true).first_or_create
      pp calendar.errors

term1 = CalendarEventType.where(title: 'Term 1', description: 'Autumn Half Term 1', occupied: true, term_time: true).first_or_create
term2 = CalendarEventType.where(title: 'Term 2', description: 'Autumn Half Term 2', occupied: true, term_time: true).first_or_create
term3 = CalendarEventType.where(title: 'Term 3', description: 'Spring Half Term 1', occupied: true, term_time: true).first_or_create
term4 = CalendarEventType.where(title: 'Term 4', description: 'Spring Half Term 2', occupied: true, term_time: true).first_or_create
term5 = CalendarEventType.where(title: 'Term 5', description: 'Summer Half Term 1', occupied: true, term_time: true).first_or_create
term6 = CalendarEventType.where(title: 'Term 6', description: 'Autumn Half Term 2', occupied: true, term_time: true).first_or_create

      CSV.foreach(csv_file, headers: true) do |row|
        next if row["Term"].nil?
        event_type = CalendarEventType.select { |cet| row["Term"].include? cet.title }.first
        calendar.calendar_events.create(title: row["Term"], start_date: row["Start Date"], end_date: row["End Date"], calendar_event_type: event_type)
      end
    end
  end
end
