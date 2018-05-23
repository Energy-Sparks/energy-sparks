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

        meter = school.meters.find_or_create_by!(meter_type: meter_type, meter_no: generate_meter_number(meter_type))

        date = row['date']
        readings = row[5..-1]

        readings.each_with_index do |reading, index|
          # read_at
          read_at = DateTime.strptime(date, "%d/%m/%Y") + (index * 30).minutes
          meter.meter_readings.find_or_create_by!(read_at: read_at, value: reading, unit: "kWh")
        end
      end
    end

    def self.generate_meter_number(meter_type)
      if meter_type == :electricity
        13.times.map { rand(10) }.join
      else
        10.times.map { rand(10) }.join
      end
    end
  end
end
