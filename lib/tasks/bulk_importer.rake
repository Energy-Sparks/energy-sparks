require 'csv'

namespace :socrata do
  desc 'Verify gas and update against socrata data'

  task :bulk_import, [:urn] => [:environment] do |_t, args|
    urn = args[:urn] || 109328 # St Marks
    school = School.find_by(urn: urn)
    pp "Running for school #{school.name}"
    delete_and_insert(school)
  end

  def delete_and_insert(school)
    School.find(school.id).meters.each do |meter|
      pp "Running #{meter.mpan_mprn}"
      delete_current_meter_readings(meter.id)
      pp "Inserting #{meter.mpan_mprn}"
      insert_meter_readings(meter)
    end
  end

  def delete_current_meter_readings(meter_id)
    MeterReading.where(meter_id: meter_id).delete_all
  end

  def insert_meter_readings(meter)
    pp DateTime.current
    pp "reading count: #{MeterReading.count}"

    csv_file = "etc/bulk_import/#{meter.meter_serial_number.upcase}.csv"
    pp "#{DateTime.current} Importing #{csv_file}"

    values = []
    columns = [:meter_id, :read_at, :value, :unit]
    amr_columns = [:meter_id, :readings, :total, :verified, :when, :unit]
    amr_values = []

    CSV.foreach(csv_file, headers: true, header_converters: [:downcase, :symbol]).each do |row|
      date = if meter.meter_type == 'electricity'
               DateTime.strptime(row[:date], "%d/%m/%Y").utc
             else
               DateTime.strptime(row[:date], "%m/%d/%Y").utc
             end

      datetime = date + 30.minutes

      array_of_readings = []

      (6..(48 + 5)).each do |n|
        file_value = row[n].to_f
        values << [meter.id, datetime, file_value, 'kWh']
        datetime = datetime + 30.minutes
        array_of_readings << file_value
      end

      amr_values << [meter.id, array_of_readings, row[:total], true, date, 'kWh']
    end

    MeterReading.import columns, values, validate: false
    AggregatedMeterReading.import amr_columns, amr_values, validate: false
    pp "#{DateTime.current} Finished #{csv_file}"
  end
end

# ID,Date,Location,PostCode,Units,TotalUnits,00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10_00,10_30,11_00,11_30,12_00,12_30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18_00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30,24:00,MPRN,MSID
# ab7525885b3a669f89e889e6f9ca9a18,11/01/2014 12:00:00 AM,##(SCHOOL'S RESPONSIBILITY) Westfield Childrens Centre,BA3 3XX,kWh,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.4,0.3,0,0,0.1,0,0,0.1,0,0,0.1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9219585408,M016A0818309A6
