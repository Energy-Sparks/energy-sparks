# BATCH Process to download solar PV data from Sheffield University (c) Energy Sparks 2018-
#
# does regional triangulated weighting from a series of local PV regions as defined by Sheffield University
# outputs the results CSV files - one for each area
#
# Sheffield overview https://www.solar.sheffield.ac.uk/pvlive/api/
#
# Nearest regions: https://api0.solar.sheffield.ac.uk/pvlive/v1/gsp_list
# 152	Iron Acton	IROA	51.56933	-2.47937	0.210050103
# 198	Melksham	MELK	51.39403	-2.14938	0.220656804
# 253	Seabank	SEAB	51.53663	-2.66869	0.332740249
#
# get data: url = 'https://api0.solar.sheffield.ac.uk/pvlive/v1?region_id=253&extra_fields=installedcapacity_mwp,site_count&start=2018-05-01T12:00:00&end=2018-05-08T23:59:59'
#
# FYI: the terminology usage in the code can be a little confusing, the term 'area' more closely replated to the term used
#      in Energy Sparks e.g. 'Bath' and defined a number of goegraphically related schools
#      the term 'region' is that of the Sheffield solar feed, and related to solar PV regions
#      there are potentially many 'regions' for each 'area'
#      the program triangulates (distance weighted average) PV data from a number of regions
#       to determine a single set of data for an area
#

require 'net/http'
require 'json'
require 'date'

@start_date = Date.new(2014, 1, 1)
@end_date = Date.new(2018, 5, 10)

@areas = {    # probably not the same areas as the other inputs, more critical they are local, so schools to west of Bath may need their own 'area'
  'Bath' => { latitude: 51.39,
              longitude: -2.37,
              proxies: [  
                          { id: 152, name: 'Iron Acton', code: 'IROA', latitude: 51.56933, longitude: -2.47937 },
                          { id: 198, name: 'Melksham', code: 'MELK', latitude: 51.39403, longitude: -2.14938 },
                          { id: 253, name: 'Seabank', code: 'SEAB', latitude: 51.53663, longitude: -2.66869 }
                        ] 
            }
}

def make_url(region_id, start_date, end_date)
  url = 'https://api0.solar.sheffield.ac.uk/pvlive/v1?'
  url += 'region_id=' + region_id.to_s + '&'
  url += '&extra_fields=capacity_mwp,site_count&'
  url += 'start=' + date_to_url_format(start_date, true) + '&'
  url += 'end=' + date_to_url_format(end_date, false)
  url
end

def date_to_url_format(date, start)
  d_url = date.strftime('%Y-%m-%d')
  d_url += start ? 'T00:00:00' : 'T23:59:59'
  d_url
end

def distance_to_area_km(latitude, longitude, proxy)
  proxy_latitude = proxy[:latitude]
  proxy_longitude = proxy[:longitude]
  distance_km = 111*((latitude-proxy_latitude)**2+(longitude-proxy_longitude)**2)**0.5
end

# for a single 'Sheffield region' download half hourly PV data (output, capacity)
# and return a hash of datetime => yield
def download_data(url) 
  solar_pv_yield = {}
  uri = URI(url)
  response = Net::HTTP.get(uri)
  data = JSON.parse(response)
  total_yield = 0.0
  data_count = 0
  data.each do |key, value|
    value.each do |components|
      id, datetimestr, generation, capacity, _stations = components
      unless generation.nil?
        time = DateTime.parse(datetimestr)
        halfhour_yield = generation / capacity
        total_yield += halfhour_yield
        solar_pv_yield[time] = halfhour_yield
        # puts "Download: #{time} #{halfhour_yield}"
        data_count += 1
      end
    end
  end
  puts "total yield #{total_yield} items #{data_count}"
  solar_pv_yield
end

def download_data_for_region(region_id, name, start_date, end_date)
  url = make_url(region_id, start_date, end_date)
  puts "Downloading PV data for region #{name} from #{start_date} to #{end_date} using #{url}"
  download_data(url)
end

def download_data_for_area(area_name, latitude, longitude, start_date, end_date)
  region_data = {}
  @areas[area_name][:proxies].each do |proxy|
    proxy_latitude = proxy[:latitude]
    proxy_longitude = proxy[:longitude]
    distance_km = 111*((latitude-proxy_latitude)**2+(longitude-proxy_longitude)**2)**0.5
    puts "id #{proxy[:id]} #{proxy[:name]} #{distance_km}"
    region_id = proxy[:id]
    name = proxy[:name]
    pv_data = download_data_for_region(region_id, name, start_date, end_date)
    region_data[name] = { distance: distance_km, data: pv_data }
  end
  region_data
end

# middle value if odd, next from middle value if even
def median(ary)
  middle = ary.size/2
  sorted = ary.sort_by{ |a| a }
  sorted[middle]
end

def process_regional_data(regional_data, start_date, end_date)
  averaged_pv_yields = {}
  # unpack the distance data for later weighted average
  distances = [] 
  regional_data.values.each do |region_data|
    distances.push(region_data[:distance])
  end

  thirty_minutes_step = (1.to_f/24/2)
  start_time = DateTime.new(start_date.year, start_date.month, start_date.day)
  end_time = DateTime.new(end_date.year, end_date.month, end_date.day, 23, 30, 0) # want to iterate to last 30 mins of day (inclusive)

  start_time.step(end_time, thirty_minutes_step).each do |dt_30mins|
    pv_values_for_30mins = []
    names = regional_data.keys

    # get data for a given 30 minute period for all 'regions'
    regional_data.values.each do |region_data|
      # puts "Looking for data for #{dt_30mins}"
      pv_data = region_data[:data]
      pv_yield = pv_data[dt_30mins]
      pv_values_for_30mins.push(pv_yield)
    end

    # processing this data, try to discard data, then return a weighted average
    median_pv = median(pv_values_for_30mins) # use median as best value for checking bad data against
    yield_diff_criteria = 0.2

    loop_count = 0
    pv_yield_sum = 0.0
    distance_sum = 0.0
    pv_values_for_30mins.each do |pv_yield|
      if pv_yield.nil?
        puts "Warning no PV yield data for #{dt_30mins}"
        loop_count += 1
        next
      end
      if pv_yield > median_pv + yield_diff_criteria || pv_yield < median_pv - yield_diff_criteria
        puts "Rejecting sample for #{names[loop_count]} on #{dt_30mins} value #{pv_yield}"
      else
        pv_yield_sum += pv_yield * distances[loop_count]
        distance_sum += distances[loop_count]
      end
      loop_count += 1
    end
    weighted_pv_yield = pv_yield_sum/distance_sum
    averaged_pv_yields[dt_30mins] = weighted_pv_yield
    # puts "average yield for #{dt_30mins} = #{weighted_pv_yield}"
  end
  averaged_pv_yields # {datetime} = yield
end

def unique_list_of_dates_from_datetimes(datetimes)
  dates = {}
  datetimes.each do |datetime|
    dates[datetime.to_date] = true
  end
  dates.keys
end

def write_csv(file, filename, data, orientation)
  # implemented using file operations as roo & write_xlsx don't seem to support writing csv and spreadsheet/csv have BOM issues on Ruby 2.5
  puts "Writing csv file #{filename}: #{data.length} items in format #{orientation}"
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
    # this bit is untested, so probably needs some work! PH 12 May 2018
    data.each do |datetime, value|
      line << datetime.strftime('%Y-%m-%d %H:%M:%S') << ',' << value.to_s << '\n'
      file.puts(line)
    end
  end  
end

def split_time_period_into_chunks
  chunk = 20 # days
  dates = []
  last_date = @start_date
  (@start_date..@end_date).step(chunk) do |date|
    last_date = (date + chunk - 1 < @end_date) ? date + chunk - 1 : @end_date
    dates.push([date, last_date])
  end
  dates
end

def download_data_for_areas()
  @areas.each do |area_name, config_data|
    latitude = config_data[:latitude]
    longitude = config_data[:longitude]
    filename = 'pv data ' + area_name + '.csv'
    File.open(filename, 'w') do |file| 
      dates = split_time_period_into_chunks # process data in chunks to avoid timeout
      dates.each do |date_range_chunk|
        start_date, end_date = date_range_chunk
        puts
        puts "========================Processing a chunk of data between #{start_date} #{end_date}=============================="
        puts
        regional_data = download_data_for_area(area_name, latitude, longitude, start_date, end_date)
        pv_data = process_regional_data(regional_data, start_date, end_date)
        write_csv(file, filename, pv_data, :landscape)
      end
    end
  end
end

download_data_for_areas
