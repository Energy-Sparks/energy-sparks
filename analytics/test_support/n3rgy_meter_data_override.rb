# takes existing unvalidated YAML from the front end
# an overrides it with manually downloaded data from n3rgy
class N3rgyMeterDataOverride
  def initialize(school)
    @school = school
  end

  def override
    puts "Overriding #{all_mpxns}"
    all_mpxns.each do |mpxn|
      csv_on_days_data = load_csv_file(mpxn)
      override_front_end_data(mpxn, csv_on_days_data) unless csv_on_days_data.nil?
    end
  end

  private

  def all_mpxns
    @school.all_meters.map(&:mpan_mprn).uniq
  end

  def load_csv_file(mpxn)
    filename = './DCC/dcc-meter_readings-' + mpxn.to_s + '.csv'
    if File.file?(filename)
      data = CSV.read(filename)
      data
    else
      nil
    end
  end

  def override_front_end_data(csv_mpxn, csv_on_days_data)
    puts "Got here not overriding #{all_mpxns}"
    return # skip for moment as raw kwh data should now be in YAML file

    all_mpxns.each do |front_end_mpxn|
      if front_end_mpxn == csv_mpxn
        amr_data = @school.meter?(csv_mpxn).amr_data
        one_days_data = csv_to_one_days_data_arr(csv_on_days_data, front_end_mpxn)
        one_days_data.each do |one_day_data|
          begin
            amr_data.add(one_day_data.date, one_day_data)
          rescue => e
            puts e.message
          end
        end
        puts "Got here #{csv_mpxn} #{one_days_data.length} rows"
      end
    end
  end

  def csv_to_one_days_data_arr(csv_on_days_data, mpxn)
    header = csv_on_days_data[0]
    csv_on_days_data.last(csv_on_days_data.length - 1).map do |row|
      date = Date.parse(row[header.index('date')])
      type = row[header.index('type')]
      kwh_x48_strs = row[header.index('0:0')..header.index('23:30')]
      kwh_x48 = kwh_x48_strs.map{ |v| v.nil? ? nil : v.to_f }
      begin
        OneDayAMRReading.new(mpxn, date, type, nil, nil, kwh_x48, true)
      rescue => e
        puts e.message
        nil
      end
    end.compact
  end
end