require "csv"

module Loader

  #Class to help load some sample school data into the database from a CSV file
  #Not for production use
  class SampleDataLoader

    def self.load!(csv_file)
      raise "File not found" unless File.exists?(csv_file)

      #school, meter_type, date, degree_days, readings...
      CSV.foreach(csv_file, {headers: :first_row, return_headers: false}) do |row|
        school = School.find_or_create_by!(name: "School #{row[0]}", school_type: School::TYPE_PRIMARY)
        meter_type = row[1] == "electric" ? 0 : 1

        #TODO: needs something more realistic
        meter_no = meter_type

        meter = Meter.find_or_create_by!(school: school, meter_type: meter_type, meter_no: 0)

        date = row[2]
        readings = row[4..-1]

        readings.each_with_index do |reading, index|
          #read_at
          read_at = DateTime.strptime( date, "%d/%m/%Y" ) + (index*30).minutes

          reading = MeterReading.find_or_create_by!( meter: meter, read_at: read_at, value: reading, unit: "kWh")
        end
      end

    end

  end
end
