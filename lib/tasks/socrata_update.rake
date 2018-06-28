require 'csv'

namespace :socrata do
  desc 'Verify and update against socrata data'
  task update: [:environment] do
    #check_and_update('gas-sorted-socrata.csv', :mprn)
    check_and_update('electricity-sorted-socrata.csv', :mpan)
    #check_and_update('13678903-gas-sorted-socrata.csv', :mprn)
  end

  def check_and_update(csv_file, meter_id_type)
    pp DateTime.current
    pp "reading count: #{MeterReading.count}"

    meter = nil
    current_meter_number = nil

    meter_good = 0
    meter_discrepancy = 0
    meter_summary = []

    mpan_mprn = nil

# ID,Date,Location,PostCode,Units,TotalUnits,00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10_00,10_30,11_00,11_30,12_00,12_30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18_00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30,24:00,MPRN,MSID
# ab7525885b3a669f89e889e6f9ca9a18,11/01/2014 12:00:00 AM,##(SCHOOL'S RESPONSIBILITY) Westfield Childrens Centre,BA3 3XX,kWh,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.4,0.3,0,0,0.1,0,0,0.1,0,0,0.1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9219585408,M016A0818309A6

    CSV.foreach(csv_file, headers: true, header_converters: [:downcase, :symbol]).select { |row| !row.empty? }.each do |row|

      date = DateTime.strptime(row[:date], "%d/%m/%Y").utc
      mpan_mprn = row[meter_id_type].to_i
      if current_meter_number != mpan_mprn
        # Summarise previous meter
        meter_summary << "#{current_meter_number}: good: #{meter_good} bad: #{meter_discrepancy}"

        meter = Meter.find_by(meter_no: mpan_mprn)

        if meter.nil?
          pp "Skip this, not a school meter #{row[:location]} #{mpan_mprn}"
        else
          pp "new meter meter_id: #{meter.meter_no} from #{row[:location]} "
          meter.update(meter_serial_number: row[:MSID], mpan_mprn: row[meter_id_type])
        end

        current_meter_number = mpan_mprn
        meter_good = 0
        meter_discrepancy = 0
      end

      if meter.present? #&& meter.meter_no = 13678903 && (date < Date.parse('5/4/2018') && date > Date.parse('1/4/2018'))
        total = row[5].to_f.round(1)
        calculated_total = (6..(48 + 5)).sum do |n|
          row[n].to_f
        end

        calculated_total = calculated_total.round(1)

        current_total = meter.meter_readings.where(read_at: date.all_day).sum(&:value).to_f.round(1)

        MeterReading.transaction do
          if current_total != total
            datetime = date + 30.minutes
            #              pp "Discrepancy: #{meter.meter_no} #{date} Total in db: #{current_total} total in file: #{total}"
            (6..(48 + 5)).each do |n|
              db_readings = meter.meter_readings.find_by(read_at: datetime)

              file_value = row[n].to_f
              if db_readings
        #       pp "At: #{datetime} db_value: #{db_readings.value} file_value #{file_value}" if db_readings.value.to_f != file_value
        #       pp db_readings
                db_readings.update(value: file_value) if db_readings.value.to_f != file_value
              else
                meter.meter_readings.create(read_at: datetime, value: file_value, unit: 'kWh')
          #      pp "At: #{datetime} NOTHING in db file_value #{file_value}"
              end
              datetime = datetime + 30.minutes
            end

            meter_discrepancy = meter_discrepancy + 1
          elsif current_total != calculated_total
            pp "Discrepancy: #{meter.meter_no} #{date} Total in db: #{current_total} calculated_total: #{calculated_total}"
            meter_discrepancy = meter_discrepancy + 1
          else
            meter_good = meter_good + 1
          end
        end
      end
    end
    pp "finished #{DateTime.current}"
    pp meter_summary
  end
end
