require "cgi"

module Loader
  class EnergyImporter
    #import data for school, starting at a specified date
    #used to onboard school without having to load entire archive of data
    def import_all_data_for(school, since_date)
      Meter.meter_types.keys.each do |type|
        import_all_data_by_type(school, type, since_date)
      end
    end

    #import data for all active meters, using date since meter was last read
    def import_new_data_for(school)
      Meter.meter_types.keys.each do |type|
        import_all_data_by_type(school, type)
      end
    end

    def import_all_data_by_type(school, type, since_date = nil)
      return unless school.meters?(type)
      find_readings(school, type, since_date) do |meter, reading|
        import_reading(meter, type, reading)
      end
    end

    def import_new_meter(meter, since_date = nil)
      find_readings_for_meter(meter, since_date) do |_meter, reading|
        import_reading(meter, meter.meter_type, reading)
      end
    end

    def find_readings(school, type, since_date = nil)
      meters(school, type).each do |meter|
        sdate = since_date.present? ? since_date : meter.last_read
        puts "Reading meter #{meter.meter_no} for data since #{sdate}"
        dataset = dataset(school, type)
        query = query(meter, type, sdate)
        client.get(dataset, query).each do |result|
          yield meter, result
        end
      end
    end

    def find_readings_for_meter(meter, since_date = nil)
      sdate = since_date.present? ? since_date : meter.last_read
      puts "Reading meter #{meter.meter_no} for data since #{sdate}"
      dataset = dataset(meter.school, meter.meter_type)
      query = query(meter, meter.meter_type, sdate)
      client.get(dataset, query).each do |result|
        yield meter, result
      end
    end

    def import_reading(meter, type, reading)
      column = meter_number_column(type)
      raise "unexpected meter number" unless meter.meter_no == reading[column].to_i
      date = DateTime.parse(reading.date).utc

      48.times.each do |n|
        read_at = date + (n * 30).minutes
        # _24_00 is first reading at midnight
        # afterwards are at 30 hourly intervals _00_30 -> _23_30
        key = n == 0 ? "_24_00" : read_at.strftime("_%H_%M")
        value = reading[key]
        r = MeterReading.find_or_create_by!(meter: meter, read_at: read_at)
        r.update_attributes!(value: value, unit: "kWh")
      end
    end

    def client
      SODA::Client.new(domain: ENV["SOCRATA_STORE"], app_token: ENV["SOCRATA_TOKEN"])
    end

    def meters(school, type)
      school.meters.where(meter_type: type, active: true)
    end

    def dataset(school, type)
      case type
      when "electricity"
        return school.electricity_dataset.present? ? school.electricity_dataset : ENV["SOCRATA_ELECTRICITY_DATASET"]
      when "gas"
        return school.gas_dataset.present? ? school.gas_dataset : ENV["SOCRATA_GAS_DATASET"]
      else
        raise "unknown meter type"
      end
    end

    def query(meter, type, since_date = nil)
      column = meter_number_column(type)
      where = '(' + "#{column}='#{meter.meter_no}'" + ')'
      # where << " AND date >='#{since_date.strftime("%Y-%m-%dT%H:%M:%S")}+00:00'" if since_date
      where << " AND date >='#{since_date.iso8601}'" if since_date
      {
          "$where" => where,
          "$order" => "date ASC",
          "$limit" => ENV["SOCRATA_LIMIT"]
      }
    end

    def meter_number_column(type)
      type == "electricity" ? "mpan" : "mprn"
    end
  end
end
