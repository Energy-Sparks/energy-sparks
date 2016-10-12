require "cgi"

module Loader

  class EnergyImporter

    def import_all_data_for(school, since_date=nil)
      Meter.meter_types.keys.each do |type|
        import_all_data_by_type(school, type, since_date)
      end
    end

    def import_all_data_by_type(school, type, since_date=nil)
      find_readings(school, type, since_date) do |reading|
        import_reading(school, type, reading)
      end
    end

    def find_readings(school, type, since_date=nil)
      #yield a reading
      dataset = dataset(school, type)
      query = query(school, type, since_date)
      client.get( dataset , query ).each do |result|
        yield result
      end
    end

    def import_reading(school, type, reading)
      #FIXME this needs to be resolved once the Socrata dataset has been fixed
      #currently have to assume all readings for same meter
      meter = school.meters.first

      date = DateTime.parse( reading.date )

      48.times.each do |n|
        read_at = date + (n * 30).minutes
        #_24_00 is first reading at midnight
        #afterwards are at 30 hourly intervals _00_30 -> _23_30
        key = n == 0 ? "_24_00" : read_at.strftime("_%H_%M")
        value = reading[key]
        r = MeterReading.find_or_create_by!(meter: meter, read_at: read_at)
        r.update_attributes!({value: value, unit: "kWh"})
      end

    end

    def client
      SODA::Client.new({:domain => ENV["SOCRATA_STORE"], :app_token => ENV["SOCRATA_TOKEN"]})
    end

    def dataset(school, type)
      case type
        when "electricity"
          return ENV["SOCRATA_ELECTRICITY_DATASET"]
        when "gas"
          return ENV["SOCRATA_GAS_DATASET"]
        else
          raise "unknown meter type"
      end
    end

    def query(school, type, since_date=nil)
      where = "location='#{ school.name }'"
      where << " AND date >= '#{since_date.iso8601}'" if since_date
      {
          "$where" => where,
          "$order" => "date ASC"
      }
    end
  end

end