require 'csv'

module Loader
  # Class to help load some sample school data into the database from a CSV file
  # Not for production use
  class SampleDataLoader
    def self.load!(csv_file)
      raise 'File not found' unless File.exist?(csv_file)
      # school, meter_type, date, degree_days, readings...
      CSV.foreach(csv_file, headers: :first_row, return_headers: false) do |row|
        school = School.find_or_create_by!(urn: row['urn'], name: "School #{row['school']}", school_type: :primary)
        meter_type = row['type'] == 'electric' ? :electricity : :gas

        # TODO: needs something more realistic
        meter_no = 0

        meter = school.meters.find_or_create_by!(meter_type: meter_type, meter_no: meter_no)

        date = row['date']
        readings = row[5..-1]

        readings.each_with_index do |reading, index|
          # read_at
          read_at = DateTime.strptime(date, "%d/%m/%Y") + (index * 30).minutes
          meter.meter_readings.find_or_create_by!(read_at: read_at, value: reading, unit: "kWh")
        end
      end
    end
  end
end
