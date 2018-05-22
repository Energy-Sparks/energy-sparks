

require 'date'
require 'open-uri'

# WEATHER UNDERGROUND TEMPERATURE AND SOLAR DATA LOADER
#
# loads temperature and weather data from Weather Underground via a URL
# - data for non-commercial , as per wu licensing
# - tries to minimise the number of URL requests
# - attempts to deal with bad data heuristically
# - averages (& discards) data from a number of weather stations
# - probably best run with end_date set at least 2 hours before run time, as
#   application automatically attempts to get data one day before and one day after requested range
#   to allow for interpolation at start and end of period
#
# I can't work out what half the lint errors in this program mean, so am commenting out the whole lot
# rubocop:disable all
@areas = [
  {
    name: 'Bath',
    start_date:  Date.new(2018, 4, 13), # may be better in controlling program
    end_date: Date.new(2018, 4, 14), # ditto, inclusive
    method:    :weighted_average,
    max_minutes_between_samples: 120, # ignore data where samples from station are too far apart
    max_temperature: 38.0,
    min_temperature: -15.0,
    max_solar_insolence: 2000.0,
    weather_stations_for_temperature:
    { # weight for averaging, selection: the weather station names are found by browsing weather underground local station data
      'ISOMERSE15'  => 0.5,
      'IBRISTOL11'  => 0.2,
      'ISOUTHGL2'   => 0.1,
      'IENGLAND120' => 0.1,
      'IBATH9'      => 0.1,
      'IBASTWER2'   => 0.1,
      'ISWAINSW2'   => 0.1,
      'IBASMIDF2'   => 0.1
    },
    weather_stations_for_solar: # has to be a temperature station for the moment - saves loading twice
    {
      'ISOMERSE15' => 0.5
    },
    temperature_csv_file_name: 'bathtemperaturedata.csv',
    solar_csv_file_name: 'bathsolardata.csv',
    csv_format: :portrait
  }
]

def generate_single_day_station_history_url(station_name, date)
  sprintf(
    "http://www.wunderground.com/weatherstation/WXDailyHistory.asp?ID=%s&year=%d&month=%d&day=%d&graphspan=day&format=1",
    station_name,
    date.year,
    date.month,
    date.day)
end

# get raw data one day/webpage at a time, data is on random minute boundaries, so not suitable for direct use
def get_raw_temperature_and_solar_data(station_name, start_date, end_date, max_temp, min_temp, max_solar)
  puts "Getting data for #{station_name} between #{start_date} and #{end_date}"
  data = {}
  (start_date..end_date).each do |date|
      puts "Processing #{date} #{station_name}"
      url = generate_single_day_station_history_url(station_name, date)
      puts "HTTP request for                     #{url}"
      header = []
      web_page = open(url){ |f|
        line_num = 0
        f.each_line do |line|
          line_components = line.split(',')
          if line_num == 1
            header = line_components
          elsif line_components.length > 2 # ideally I should use an encoding which ignores the <br> line ending coming in as a single line
            temperature_index = header.index('TemperatureC')
            solar_index = header.index('SolarRadiationWatts/m^2')
            datetime = DateTime.parse(line_components[0])
            temperature = !line_components[temperature_index].nil? ? line_components[temperature_index].to_f : nil
            solar_string = solar_index.nil? ? nil : line_components[solar_index]
            solar_value = solar_string.nil? ? nil : solar_string.to_f
            solar_value = solar_value.nil? ? nil : (solar_value < max_solar ? solar_value : nil)
            if !temperature.nil? && temperature <= max_temp && temperature >= min_temp  # only use data if the temperature is within range
              data[datetime] = [temperature, solar_value]
            end
          end
          line_num += 1
        end
      }
  end
  puts "got #{data.length} observations"
  data
end

def simple_interpolate(val1, val0, t1, t0, tx)
  t_prop = (tx - t0) / (t1 - t0)
  val0 + (val1 - val0) * t_prop
end

def interpolate_rawdata_onto_30minute_boundaries(station_name, rawdata, start_date, end_date, max_minutes_between_samples)
  puts "station_name = #{station_name}"
  puts "Interpolating data onto 30min boundaries for #{station_name} between #{start_date} and #{end_date} => #{rawdata.length} samples"
  temperatures = []
  solar_insolance = []

  start_time = start_date.to_datetime
  end_time = end_date.to_datetime

  date_times = rawdata.keys
  mins30step = (1.to_f/48)

  start_date.to_datetime.step(end_date.to_datetime, mins30step).each do |datetime|

    closest = date_times.bsearch{|x| x >= datetime }
    index = date_times.index(closest)

    time_before = date_times[index-1]
    time_after = date_times[index]
    minutes_between_samples = (time_after - time_before) * 24 * 60

    if minutes_between_samples <= max_minutes_between_samples
      # process temperatures

      temp_before = rawdata[date_times[index-1]][0]
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
  start_date = area[:start_date]
  end_date   = area[:end_date]
  max_minutes_between_samples = area[:max_minutes_between_samples]
  max_temp = area[:max_temperature]
  min_temp = area[:min_temperature]
  max_solar = area[:max_solar_insolence]

  # load the raw data from webpages for each station (one day at a time)
  rawstationdata = {}
  area[:weather_stations_for_temperature].each do |station_name, weight|
    rawdata = get_raw_temperature_and_solar_data(station_name, start_date-1, end_date+1, max_temp, min_temp, max_solar)
    if !rawdata.empty?
      rawstationdata[station_name] = rawdata
    else
      puts "Warning: no data for station #{station_name}"
    end
  end

  # process the raw data onto 30 minute boundaries
  processeddata = {}
  rawstationdata.each do |station_name, rawdata|
    processeddata[station_name] = interpolate_rawdata_onto_30minute_boundaries(station_name, rawdata, start_date, end_date, max_minutes_between_samples)
  end

  # take temperatures, solar from muliple weather stations and calculate a weighted average across a number of local weather stations
  temperatures = {}
  solar_insolence = {}
  if area[:method] == :weighted_average  # for every 30 minutes in period loop through all the station data averaging
    mins30step = (1.to_f/48)

    loop_count = 0
    start_date.to_datetime.step(end_date.to_datetime, mins30step).each do |datetime|
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

      avg_temp = sample_weight_temp> 0.0 ? (avg_sum_temp / sample_weight_temp).round(2) : nil
      avg_solar = sample_weight_solar > 0.0 ? (avg_sum_solar / sample_weight_solar).round(2) : nil
      temperatures[datetime] = avg_temp
      solar_insolence[datetime] = avg_solar
      loop_count += 1
    end
  else
    raise "Unknown weather station processing method for #{area[:name]} area[:method]"
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
          if  data.key?(datetime)
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
      data.each do |datetime, value|
        line << datetime.strftime('%Y-%m-%d %H:%M:%S') << ',' << value.to_s << '\n'
        file.puts(line)
      end
    end
  end
end

# MAIN

@areas.each do |area|
  temperatures, solar_insolence = process_area(area)

  write_csv(area[:temperature_csv_file_name], temperatures, area[:csv_format])
  write_csv(area[:solar_csv_file_name], solar_insolence, area[:csv_format])

end


