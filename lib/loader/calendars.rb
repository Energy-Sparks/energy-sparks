require 'csv'

module Loader
  class Calendars
    # load default calendar from csv
    def self.load!(csv_file = 'etc/banes-default-calendar.csv', group)
      raise 'File not found' unless File.exist?(csv_file)
      data_hash = CSV.foreach(csv_file, headers: true, header_converters: :symbol).select { |row| !row.empty? }.map(&:to_h)
      CalendarFactoryFromEventHash.new(data_hash, group, true).create
    end
  end
end
