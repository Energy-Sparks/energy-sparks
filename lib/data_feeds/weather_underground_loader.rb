module DataFeeds
  class WeatherUndergroundLoader
    # This will actually fire up and get the data
    # Default start and end dates can be removed once all working
    def initialize(start_date = Date.new(2018, 4, 13), end_date = Date.new(2018, 4, 13))
      @start_date = start_date
      @end_date = end_date
      @method = :weighted_average
      @max_temperature = 38.0
      @min_temperature = -15.0
      @max_minutes_between_samples = 120
      @max_solar_onsolence = 2000.0
      @csv_format = :landscape
    end

    def import
      WeatherUndergroundArea.all.each do |wua|
        wua.data_feeds.each do |data_feed|
          area = data_feed.configuration.symbolize_keys
          pp area
          pp "Running for #{area[:name]}"
          temperatures, solar_insolence = process_area(area)

          pp temperatures

          write_csv(area[:temperature_csv_file_name], temperatures, @csv_format)
          write_csv(area[:solar_csv_file_name], solar_insolence, @csv_format)
        end
      end
    end

    # get raw data one day/webpage at a time, data is on random minute boundaries, so not suitable for direct use
    def get_raw_temperature_and_solar_data(station_name, start_date = @start_date - 1, end_date = @end_date + 1)
      puts "Getting data for #{station_name} between #{start_date} and #{end_date}"
      data = {}
      (start_date.to_date..end_date.to_date).each do |date|
        puts "Processing #{date} #{station_name}"
        url = generate_single_day_station_history_url(station_name, date)
        puts "HTTP request for                     #{url}"
        header = []
        open(url) do |f|
          line_num = 0

          f.each_line do |line|
            line_components = line.split(',')
            if line_num == 1
              header = line_components
            elsif line_components.length > 2 # ideally I should use an encoding which ignores the <br> line ending coming in as a single line
              temperature_index = header.index('TemperatureC')
              solar_index = header.index('SolarRadiationWatts/m^2')
              datetime =  Time.zone.parse(line_components[0])
              temperature = !line_components[temperature_index].nil? ? line_components[temperature_index].to_f : nil
              solar_string = solar_index.nil? ? nil : line_components[solar_index]
              solar_value = solar_string.nil? ? nil : solar_string.to_f
              solar_value = if solar_value.nil?
                              nil
                            elsif solar_value < @max_solar_onsolence
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
        "http://www.wunderground.com/weatherstation/WXDailyHistory.asp?ID=%s&year=%d&month=%d&day=%d&graphspan=day&format=1",
        station_name,
        date.year,
        date.month,
        date.day)
    end

    def simple_interpolate(val1, val0, t1, t0, tx)
      t_prop = (tx - t0) / (t1 - t0)
      val0 + (val1 - val0) * t_prop
    end

    def interpolate_rawdata_onto_30minute_boundaries(station_name, rawdata)
      puts "station_name = #{station_name}"
      puts "Interpolating data onto 30min boundaries for #{station_name} between #{@start_date} and #{@end_date} => #{rawdata.length} samples"
      temperatures = []
      solar_insolance = []

      start_time = @start_date.to_datetime
      end_time = @end_date.to_datetime

      date_times = rawdata.keys
      mins30step = (1.to_f / 48)

      pp @start_date.to_datetime
      pp @end_date.to_datetime

      @start_date.to_datetime.step(@end_date.to_datetime, mins30step).each do |datetime|
        closest = date_times.bsearch { |x| x >= datetime }
        index = date_times.index(closest)

        time_before = date_times[index - 1]
        time_after = date_times[index]
        minutes_between_samples = (time_after - time_before) * 24 * 60

    #    binding.pry

        if minutes_between_samples <= @max_minutes_between_samples
          # process temperatures

          temp_before = rawdata[date_times[index - 1]][0]
          temp_after = rawdata[date_times[index]][0]
          temp_val = simple_interpolate(temp_after.to_f, temp_before.to_f, time_after, time_before, datetime).round(2)

          temperatures.push(temp_val)

          # process solar insolence

          solar_before = rawdata[date_times[index - 1]][1]
          solar_after = rawdata[date_times[index]][1]
          solar_val = simple_interpolate(solar_after.to_f, solar_before.to_f, time_after, time_before, datetime).round(2)
          solar_insolance.push(solar_val)
        else
          temperatures.push(nil)
          solar_insolance.push(nil)
        end
      end
      [temperatures, solar_insolance]
    end

    def process_area(area)
      puts '=' * 80
      puts area.inspect
      puts "Processing area #{area[:name]}"

      # load the raw data from webpages for each station (one day at a time)
      rawstationdata = {}

      # QUESTION - is weight not actually used? Doesn't seem to be in this block
      area[:weather_stations_for_temperature].each do |station_name, _weight|
        rawdata = get_raw_temperature_and_solar_data(station_name, @start_date - 1, @end_date + 1)
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
      solar_insolence = {}
      if @method == :weighted_average # for every 30 minutes in period loop through all the station data averaging
        mins30step = (1.to_f / 48)

        loop_count = 0
        @start_date.to_datetime.step(@end_date.to_datetime, mins30step).each do |datetime|
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
          solar_insolence[datetime] = avg_solar
          loop_count += 1
        end
      else
        raise "Unknown weather station processing method for #{area[:name]} @method"
      end
      [temperatures, solar_insolence]
    end

    def unique_list_of_dates_from_datetimes(datetimes)
      dates = {}
      datetimes.each do |datetime|
        dates[datetime.to_date] = true
      end
      dates.keys
    end

    def write_csv(filename, data, orientation)
      # implemented using file operations as roo & write_xlsx don't seem to support writing csv and spreadsheet/csv have BOM issues on Ruby 2.5
      puts "Writing csv file #{filename}: #{data.length} items in format #{orientation}"
      File.open(filename, 'w') do |file|
        if orientation == :landscape
          dates = unique_list_of_dates_from_datetimes(data.keys)
          dates.each do |date|
            line = date.strftime('%Y-%m-%d') << ','
            (0..47).each do |half_hour_index|
              datetime = DateTime.new(date.year, date.month, date.day, (half_hour_index / 2).to_i, half_hour_index.even? ? 0 : 30, 0)
              if data.key?(datetime)
                if data[datetime].nil?
                  line << ','
                else
                  line << data[datetime].to_s << ','
                end
              end
            end
            file.puts(line)
          end
        else
          line = []
          data.each do |datetime, value|
            line << datetime.strftime('%Y-%m-%d %H:%M:%S') << ',' << value.to_s << '\n'
            file.puts(line)
          end
        end
      end
    end
  end
end
