require "cgi"

module Loader
  class EnergyImporter
    # (re)import all data for a school
    def import_all_data!(school)
      Meter.meter_types.keys.each do |type|
        import_all_data_by_type(school, type, nil)
      end
    end

    def import_all_data_for(school, since_date = nil)
      Meter.meter_types.keys.each do |type|
        import_all_data_by_type(school, type, since_date)
      end
    end

    def import_new_data_for(school)
      since_date = meters_last_read(school)
      import_all_data_for(school, since_date)
    end

    def import_all_data_by_type(school, type, since_date = nil)
      return unless school.meters?(type)
      find_readings(school, type, since_date) do |reading|
        import_reading(school, type, reading)
      end
    end

    def import_new_data_by_type(school, type)
      since_date = meters_last_read(school)
      import_all_data_by_type(school, type, since_date)
    end

    def find_readings(school, type, since_date = nil)
      # yield a reading
      dataset = dataset(school, type)
      query = query(school, type, since_date)

      client.get(dataset, query).each do |result|
        yield result
      end
    end

    def import_reading(_school, type, reading)
      column = meter_number_column(type)

      meter = Meter.find_by_meter_no(reading[column])
      return unless meter

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

    def dataset(_school, type)
      case type
      when "electricity"
        return ENV["SOCRATA_ELECTRICITY_DATASET"]
      when "gas"
        return ENV["SOCRATA_GAS_DATASET"]
      else
        raise "unknown meter type"
      end
    end

    def meters_last_read(school)
      last_read = []
      school.meters.each do |m| last_read.push(m.last_read) end
      last_read.include?(nil) ? nil : last_read.sort.first
    end

    def query(school, type, since_date = nil)
      column = meter_number_column(type)
      where = '(' + school.meters.where(meter_type: type).order(:meter_no).map { |m| "#{column}='#{m.meter_no}'" }.join(" OR ") + ')'
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
