require 'sun_times'

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

      @errors = []

      @yield_diff_criteria = 0.2 # if 3 or more samples, then reject any yields this far away from median
      @dates = split_time_period_into_chunks # process data in chunks to avoid timeout
    end

    def import
      SolarPvTuosArea.all.each do |sa|
        sa.data_feeds.each do |data_feed|
          config_data = data_feed.configuration.deep_symbolize_keys
          area_name = config_data[:name]

          latitude = config_data[:latitude]
          longitude = config_data[:longitude]
          filename = "#{area_name.downcase}solar_pvdata.csv"

          @dates.each do |date_range_chunk|
            process_data_for_each_chunk(config_data, data_feed, date_range_chunk, filename, latitude, longitude)
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
            halfhour_yield = generation / capacity / 2.0
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

    def download_data_for_area(latitude, longitude, start_date, end_date, proxies)
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

    # check for sunrise (margin = hours after sunrise, before sunset test applied)
    def daytime?(datetime, latitude, longitude, margin_hours)
      sun_times = SunTimes.new

      sunrise = sun_times.rise(datetime, latitude, longitude)
      sr_criteria = sunrise + 60 * 60 * margin_hours
      sr_criteria_dt = DateTime.parse(sr_criteria.to_s).utc # crudely convert to datetime, avoid time as very slow on Windows

      sunset = sun_times.set(datetime, latitude, longitude)
      ss_criteria = sunset - 60 * 60 * margin_hours
      ss_criteria_dt = DateTime.parse(ss_criteria.to_s).utc # crudely convert to datetime, avoid time as very slow on Windows

      datetime > sr_criteria_dt && datetime < ss_criteria_dt
    end

    def distance_to_climate_zone_km(latitude, longitude, proxy)
      proxy_latitude = proxy[:latitude]
      proxy_longitude = proxy[:longitude]
      111 * ((latitude - proxy_latitude)**2 + (longitude - proxy_longitude)**2)**0.5
    end

    # middle value if odd, next from middle value if even
    def median(ary)
      middle = ary.size / 2
      sorted = ary.sort
      sorted[middle]
    end

    def remove_outliers(data, distances, names, datetime)
      bad_indexes = []

      median_yield = median(data)

      # if too far from median remove
      data.each_with_index do |entry, index|
        if entry > median_yield + @yield_diff_criteria || entry < median_yield - @yield_diff_criteria
          bad_indexes.push(index)
          message = "Warning: rejecting yield for #{names[index]} value #{entry} from values #{data} for #{datetime}"
          puts message
          @errors.push(message)
        end
      end
      # then remove them from the analysis
      bad_indexes.each do |j|
        data.delete_at(j)
        names.delete_at(j)
        distances.delete_at(j)
      end
    end

    def proximity_weighted_average(data, distances)
      inverse_distance_sum = 0
      weighted_yield_sum = 0
      data.each_with_index do |entry, index|
        inverse_distance = 1.0 / distances[index]
        weighted_yield_sum += entry * inverse_distance
        inverse_distance_sum += inverse_distance
      end
      weighted_yield_sum / inverse_distance_sum
    end

    def remove_nil_values(data, names, distances, datetime, latitude, longitude)
      bad_indexes = []
      data.each_with_index do |entry, index|
        if entry.nil?
          bad_indexes.push(index)
          message = "Warning: nil value for #{datetime} #{names[index]}, ignoring" if daytime?(datetime, latitude, longitude, 1.5)
          puts message
          @errors.push(message)
        end
      end

      # then remove them from the analysis
      bad_indexes.each do |i|
        data.delete_at(i)
        names.delete_at(i)
        distances.delete_at(i)
      end
    end

    def calculate_average(data, names, distances, latitude, longitude, datetime)
      remove_nil_values(data, names, distances, datetime, latitude, longitude)
      calculated_yield = 0.0
      if data.length.zero? || (data.length == 1 && data[0].nil?)
        if daytime?(datetime, latitude, longitude, 2)
          message = "Error: no yield data available from any source on #{datetime}"
          puts message
          @errors.push(message)
        end
        calculated_yield = 0.0
      elsif data.length == 1
        calculated_yield = data[0]
      elsif data.length == 2
        calculated_yield = proximity_weighted_average(data, distances)
      else # vote on value
        remove_outliers(data, distances, names, datetime)
        calculated_yield = proximity_weighted_average(data, distances)
      end
      calculated_yield
    end

    def process_regional_data(regional_data, start_date, end_date, latitude, longitude)
      averaged_pv_yields = {}
      # unpack the distance data for later weighted average
      distances = []
      names = []
      regional_data.each do |name, region_data|
        distances.push(region_data[:distance])
        names.push(name)
      end

      thirty_minutes_step = (1.to_f / 24 / 2)
      start_time = Time.zone.local(start_date.year, start_date.month, start_date.day).to_datetime
      end_time = Time.zone.local(end_date.year, end_date.month, end_date.day, 23, 30, 0).to_datetime # want to iterate to last 30 mins of day (inclusive)
      start_time.step(end_time, thirty_minutes_step).each do |dt_30mins|
        pv_values_for_30mins = []

        # get data for a given 30 minute period for all 'regions'
        regional_data.values.each do |region_data|
          # puts "Looking for data for #{dt_30mins}"
          pv_data = region_data[:data]
          pv_yield = pv_data[dt_30mins]
          pv_values_for_30mins.push(pv_yield)
        end

        weighted_pv_yield = calculate_average(pv_values_for_30mins, names.clone, distances.clone, latitude, longitude, dt_30mins)

        averaged_pv_yields[dt_30mins] = weighted_pv_yield
        # puts "average yield for #{dt_30mins} = #{weighted_pv_yield}"
      end
      averaged_pv_yields # {datetime} = yield
    end

    # USED BY OLD WRITE CSV
    # def unique_list_of_dates_from_datetimes(datetimes)
    #   dates = {}
    #   datetimes.each do |datetime|
    #     dates[datetime.to_date] = true
    #   end
    #   dates.keys
    # end

    # def write_csv(file, filename, data, orientation)
    #   # implemented using file operations as roo & write_xlsx don't seem to support writing csv and spreadsheet/csv have BOM issues on Ruby 2.5
    #   puts "Writing csv file #{filename}: #{data.length} items in format #{orientation}"
    #   if orientation == :landscape
    #     dates = unique_list_of_dates_from_datetimes(data.keys)
    #     dates.each do |date|
    #       line = date.strftime('%Y-%m-%d') << ','
    #       (0..47).each do |half_hour_index|
    #         datetime = DateTime.new(date.year, date.month, date.day, (half_hour_index / 2).to_i, half_hour_index.even? ? 0 : 30, 0)
    #         if  data.key?(datetime)
    #           if data[datetime].nil?
    #             line << ','
    #           else
    #             line << data[datetime].to_s << ','
    #           end
    #         end
    #       end
    #       file.puts(line)
    #     end
    #   else
    #     # this bit is untested, so probably needs some work! PH 12 May 2018
    #     data.each do |datetime, value|
    #       line << datetime.strftime('%Y-%m-%d %H:%M:%S') << ',' << value.to_s << '\n'
    #       file.puts(line)
    #     end
    #   end
    # end

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

  private

    def process_data_for_each_chunk(config_data, data_feed, date_range_chunk, filename, latitude, longitude)
      start_date, end_date = date_range_chunk
      puts
      puts "========================Processing a chunk of data between #{start_date} #{end_date}=============================="
      puts
      regional_data = download_data_for_area(latitude, longitude, start_date, end_date, config_data[:proxies])
      pv_data = process_regional_data(regional_data, start_date, end_date, latitude, longitude)

      WeatherUndergroundCsvWriter.new(filename, pv_data, @csv_format).write_csv
      pv_data.each do |datetime, value|
        DataFeedReading.create(at: datetime, data_feed: data_feed, value: value, feed_type: :solar_pv) unless value.nan?
      end

      pv_readings = data_feed.readings(:solar_pv, @start_date, @end_date)
      File.open("from-db-#{filename}", 'w') {|file| file.write(data_feed.to_csv(pv_readings))}
    end

    # def process_30_minute_steps(averaged_pv_yields, distances, dt_30mins, regional_data)
    #   pv_values_for_30mins = []
    #   names = regional_data.keys

    #   # get data for a given 30 minute period for all 'regions'
    #   regional_data.values.each do |region_data|
    #     # puts "Looking for data for #{dt_30mins}"
    #     get_pv_values_for_30_mins(dt_30mins, pv_values_for_30mins, region_data)
    #   end

    #   # processing this data, try to discard data, then return a weighted average
    #   median_pv = median(pv_values_for_30mins) # use median as best value for checking bad data against
    #   yield_diff_criteria = 0.2

    #   loop_count = 0
    #   pv_yield_sum = 0.0
    #   distance_sum = 0.0
    #   pv_values_for_30mins.each do |pv_yield|
    #     if pv_yield.nil?
    #       puts "Warning no PV yield data for #{dt_30mins}"
    #       loop_count += 1
    #       next
    #     end
    #     if pv_yield > median_pv + yield_diff_criteria || pv_yield < median_pv - yield_diff_criteria
    #       puts "Rejecting sample for #{names[loop_count]} on #{dt_30mins} value #{pv_yield}"
    #     else
    #       pv_yield_sum += pv_yield * distances[loop_count]
    #       distance_sum += distances[loop_count]
    #     end
    #     loop_count += 1
    #   end
    #   weighted_pv_yield = pv_yield_sum / distance_sum
    #   averaged_pv_yields[dt_30mins] = weighted_pv_yield
    # end

    # def get_pv_values_for_30_mins(dt_30mins, pv_values_for_30mins, region_data)
    #   pv_data = region_data[:data]
    #   pv_yield = pv_data[dt_30mins]
    #   pv_values_for_30mins.push(pv_yield)
    # end
  end
end
