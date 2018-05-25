module DataFeeds
  class SolarPvTuosLoader
    # This will actually fire up and get the data
    # Default start and end dates can be removed once all working
    def initialize(start_date = Date.new(2018, 4, 13), end_date = Date.new(2018, 4, 14))
      @start_date = start_date
      @end_date = end_date
      @method = :weighted_average
      @max_temperature = 38.0
      @min_temperature = -15.0
      @max_minutes_between_samples = 120
      @max_solar_onsolence = 2000.0
      @csv_format = :portrait
    end

    def import
      pp "No action yet"
      SolarPvTuosArea.all.each do |sa|
        sa.data_feeds.each do |data_feed|
          area = data_feed.configuration.deep_symbolize_keys

          area_name = area[:name]
          config_data = area

          latitude = config_data[:latitude]
          longitude = config_data[:longitude]
          filename = "#{area_name.downcase}solar_pvdata.csv"

          dates = split_time_period_into_chunks # process data in chunks to avoid timeout
          dates.each do |date_range_chunk|
            start_date, end_date = date_range_chunk
            puts
            puts "========================Processing a chunk of data between #{start_date} #{end_date}=============================="
            puts
            regional_data = download_data_for_area(area_name, latitude, longitude, start_date, end_date, area[:proxies])
            pv_data = process_regional_data(regional_data, start_date, end_date)

            WeatherUndergroundCsvWriter.new(filename, pv_data, @csv_format).write_csv
            pv_data.each do |datetime, value|
              DataFeedReading.create(at: datetime, data_feed: data_feed, value: value, feed_type: :solar_pv)
            end

            File.open("from-db-#{filename}", 'w') { |file| file.write(data_feed.to_csv(:solar_pv, @start_date, @end_date)) }
          end
        end
      end
    end

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
      distance_km = 111 * ((latitude - proxy_latitude)**2 + (longitude - proxy_longitude)**2)**0.5
      distance_km
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
      data.each do |_key, value|
        value.each do |components|
          _id, datetimestr, generation, capacity, _stations = components
          unless generation.nil?
            time = Time.zone.parse(datetimestr).to_datetime
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

    def download_data_for_area(_area_name, latitude, longitude, start_date, end_date, proxies)
      region_data = {}
      proxies.each do |proxy|
        pp proxy
        proxy_latitude = proxy[:latitude]
        proxy_longitude = proxy[:longitude]
        distance_km = 111 * ((latitude - proxy_latitude)**2 + (longitude - proxy_longitude)**2)**0.5
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
      middle = ary.size / 2
      sorted = ary.sort
      sorted[middle]
    end

    def process_regional_data(regional_data, start_date, end_date)
      averaged_pv_yields = {}
      # unpack the distance data for later weighted average
      distances = []
      regional_data.values.each do |region_data|
        distances.push(region_data[:distance])
      end

      thirty_minutes_step = (1.to_f / 24 / 2)
      start_time = Time.zone.local(start_date.year, start_date.month, start_date.day).to_datetime
      end_time = Time.zone.local(end_date.year, end_date.month, end_date.day, 23, 30, 0).to_datetime # want to iterate to last 30 mins of day (inclusive)

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
        weighted_pv_yield = pv_yield_sum / distance_sum
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

    def split_time_period_into_chunks
      chunk = 20 # days
      dates = []
      last_date = @start_date
      (@start_date..@end_date).step(chunk) do |date|
        last_date = date + chunk - 1 < @end_date ? date + chunk - 1 : @end_date
        dates.push([date, last_date])
      end
      dates
    end
  end
end
