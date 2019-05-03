module DataFeeds
  class WeatherUndergroundLoader
    # This will actually fire up and get the data
    # Default start and end dates can be removed once all working
    def initialize(start_date = Date.new(2018, 4, 13), end_date = Date.new(2018, 4, 14))
      @start_date = start_date
      @end_date = end_date
      @method = :weighted_average
      @max_temperature = 38.0
      @min_temperature = -15.0
      @max_minutes_between_samples = 120
      @max_solar_irradiation = 2000.0
      @csv_format = :landscape
    end

    def import
      WeatherUndergroundArea.all.each do |wua|
        wua.data_feeds.each do |data_feed|
          area = data_feed.configuration.symbolize_keys
          pp "Running for #{area[:name]}"
          temperatures, solar_irradiation = process_area(area)

          temperatures.each do |datetime, value|
            DataFeedReading.create(at: datetime, data_feed: data_feed, value: value, feed_type: :temperature) unless value.nil?
          end

          solar_irradiation.each do |datetime, value|
            DataFeedReading.create(at: datetime, data_feed: data_feed, value: value, feed_type: :solar_irradiation) unless value.nil?
          end
        end
      end
    end

    def process_area(area)
      puts '=' * 80
      puts area.inspect
      puts "Processing area #{area[:name]}"

      # load the raw data from webpages for each station (one day at a time)
      rawstationdata = {}

      area[:weather_stations_for_temperature].each do |station_name, _weight|
        rawdata = get_raw_temperature_and_solar_data(station_name, @start_date, @end_date)
        if !rawdata.empty?
          rawstationdata[station_name] = rawdata
        else
          puts "Warning: no data for station #{station_name}"
        end
      end

      # process the raw data onto 30 minute boundaries
      processeddata = {}
      rawstationdata.each do |station_name, rawdata|
        processeddata[station_name] = interpolate_rawdata_onto_30minute_boundaries(station_name, rawdata)
      end

      # take temperatures, solar from muliple weather stations and calculate a weighted average across a number of local weather stations
      temperatures = {}
      solar_irradiation = {}
      if @method == :weighted_average # for every 30 minutes in period loop through all the station data averaging
        mins30step = (1.to_f / 48)

        loop_count = 0
        @start_date.to_datetime.step(@end_date.end_of_day.to_datetime, mins30step).each do |datetime|
          avg_sum_temp = 0.0
          sample_weight_temp = 0.0

          avg_sum_solar = 0.0
          sample_weight_solar = 0.0

          processeddata.each do |station_name, data|
            # average temperatures
            if !data[0][loop_count].nil?
              temp_weight = area[:weather_stations_for_temperature][station_name]
              avg_sum_temp += data[0][loop_count] * temp_weight
              sample_weight_temp += temp_weight
            end

            # average solar insolence
            if !data[1][loop_count].nil? && area[:weather_stations_for_solar].key?(station_name)
              solar_weight = area[:weather_stations_for_solar][station_name]
              avg_sum_solar += data[1][loop_count] * solar_weight
              sample_weight_solar += solar_weight
            end
          end

          avg_temp = sample_weight_temp > 0.0 ? (avg_sum_temp / sample_weight_temp).round(2) : nil
          avg_solar = sample_weight_solar > 0.0 ? (avg_sum_solar / sample_weight_solar).round(2) : nil
          temperatures[datetime] = avg_temp
          solar_irradiation[datetime] = avg_solar
          loop_count += 1
        end
      else
        raise "Unknown weather station processing method for #{area[:name]} @method"
      end
      [temperatures, solar_irradiation]
    end

    def get_raw_temperature_and_solar_data(station_name, start_date, end_date)
      puts "Getting data for #{station_name} between #{start_date} and #{end_date}"
      data = {}
      (start_date..end_date).each do |date|
        puts "Processing #{date} #{station_name}"
        url = generate_single_day_station_history_url(station_name, date)
        puts "HTTP request for                     #{url}"
        header = []
        uri = URI.parse(url) #=> #<URI::HTTP>
        uri.open do |f|
          line_num = 0
          f.each_line do |line|
            line_components = line.split(',')
            if line_num == 1
              header = line_components
            elsif line_components.length > 2 # ideally I should use an encoding which ignores the <br> line ending coming in as a single line
              solar_index = header.index('SolarRadiationWatts/m^2')
              datetime = Time.zone.parse(line_components[0]).to_datetime

              temperature_index_f = header.index('TemperatureF')
              temperature_index_c = header.index('TemperatureC')

              temperature_index = temperature_index_f || temperature_index_c

              temperature = !line_components[temperature_index].nil? ? line_components[temperature_index].to_f : nil

              if temperature_index_c.nil?
                # Convert to F
                temperature = (temperature - 32) / 1.8
              end

              solar_string = solar_index.nil? ? nil : line_components[solar_index]
              solar_value = solar_string.nil? ? nil : solar_string.to_f
              solar_value = if solar_value.nil?
                              nil
                            elsif solar_value < @max_solar_irradiation
                              solar_value
                            end
              if !temperature.nil? && temperature <= @max_temperature && temperature >= @min_temperature # only use data if the temperature is within range
                data[datetime] = [temperature, solar_value]
              end
            end
            line_num += 1
          end
        end
      end
      puts "got #{data.length} observations"
      data
    end

    def generate_single_day_station_history_url(station_name, date)
      sprintf(
        "https://www.wunderground.com/weatherstation/WXDailyHistory.asp?ID=%s&year=%d&month=%d&day=%d&graphspan=day&format=1",
        station_name,
        date.year,
        date.month,
        date.day)
    end

    # rubocop:disable Naming/UncommunicativeMethodParamName
    def simple_interpolate(val1, val0, t1, t0, tx, debug = false)
      t_prop = (tx - t0) / (t1 - t0)
      res = val0 + (val1 - val0) * t_prop
      puts "Interpolate: T1 #{val1} T0 #{val0} dt1 #{t1} dt0 #{t0} at dt #{tx}" if debug
      res
    end
    # rubocop:enable Naming/UncommunicativeMethodParamName

    def interpolate_rawdata_onto_30minute_boundaries(station_name, rawdata)
      puts "station_name = #{station_name}"
      puts "Interpolating data onto 30min boundaries for #{station_name} between #{@start_date} and #{@end_date} => #{rawdata.length} samples"
      temperatures = []
      solar_insolance = []

      start_time = @start_date.to_datetime
      end_time = @end_date.to_datetime.beginning_of_day + 1.day

      date_times = rawdata.keys
      mins30step = (1.to_f / 48)

      start_time.step(end_time, mins30step).each do |datetime|
        begin
          if date_times.last < datetime
            puts "Problem shortage of data for this weather station, terminating interpolation early at #{datetime}"
            return [temperatures, solar_insolance]
          end
          index = date_times.bsearch_index {|x, _| x >= datetime } # closest

          time_before = date_times[index - 1]
          time_after = date_times[index]

          minutes_between_samples = (time_after - time_before) * 24 * 60

          if minutes_between_samples <= @max_minutes_between_samples && datetime > date_times.first
            # process temperatures

            temp_before = rawdata[date_times[index - 1]][0]
            temp_after = rawdata[date_times[index]][0]
            debug = !@debug_start_date.nil? && datetime >= @debug_start_date && datetime <= @debug_end_date

            temp_val = simple_interpolate(temp_after.to_f, temp_before.to_f, time_after, time_before, datetime, debug).round(2)
            temperatures.push(temp_val)

            if debug
              puts "Interpolation for #{station_name} #{datetime} T = #{temp_before} to #{temp_after} => #{temp_val}"
              puts "mins between samples #{minutes_between_samples} versus limit #{@max_minutes_between_samples}"
            end
            # process solar insolence

            solar_before = rawdata[date_times[index - 1]][1]
            solar_after = rawdata[date_times[index]][1]
            solar_val = simple_interpolate(solar_after.to_f, solar_before.to_f, time_after, time_before, datetime).round(2)
            solar_insolance.push(solar_val)
          else
            temperatures.push(nil)
            solar_insolance.push(nil)
          end
        rescue StandardError
          puts "Data Exception at #{datetime}"
          raise
        end
      end

      [temperatures, solar_insolance]
    end
  end
end
