require 'csv'

module Loader
  class Calendars
    # load default calendar from csv
    def self.load!(csv_file = 'etc/banes-default-calendar.csv')
      raise 'File not found' unless File.exist?(csv_file)

      england = Group.where(title: 'England and Wales').first_or_create
      group = Group.where(title: 'Bristol and North East Somerset (BANES)', parent_group: england).first_or_create

      data_hash = CSV.foreach(csv_file, headers: true, header_converters: :symbol).select { |row| !row.empty? }.map(&:to_h)
      CalendarFactory.new(data_hash, group, true).create
    end
  end
end
