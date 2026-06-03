# frozen_string_literal: true

require 'date'
require 'sun_times'
require 'tzinfo'

module DataFeeds
  # Provides higher level interface to PVLive API to support bulk downloads,
  # conversion of data into preferred structure, interpolation of missing values,
  # determination of nearest areas, etc
  class PvLiveService
    def initialize(pv_live_api = PvLiveApi.new)
      @pv_live_api = pv_live_api
      @yield_diff_criteria = 0.001
      @schools_timezone = TZInfo::Timezone.get('Europe/London')
    end

    # find area matching by gsp_name
    def find_areas(name)
      data = @pv_live_api.gsp_list
      areas  = decode_areas(data[:data], data[:meta])
      areas.select do |area|
        area[:gsp_name] == name
      end
    end

    # should run minimum to 10 days, to create overlap for interpolation (missing days data only slightly fault tolerant)
    def historic_solar_pv_data(gsp_id, sunrise_sunset_latitude, sunrise_sunset_longitude, start_date, end_date)
      raise "Error: requested start_date #{start_date} earlier than first available date 2014-01-01" if start_date < Date.new(
        2014, 1, 1
      )

      pv_data, meta_data_dictionary = download_historic_data(gsp_id, start_date, end_date)
      datetime_to_yield_hash = process_pv_data(pv_data, meta_data_dictionary, sunrise_sunset_latitude,
                                               sunrise_sunset_longitude)
      pv_date_hash_to_x48_yield_array, missing_date_times, whole_day_substitutes = convert_to_date_to_x48_yield_hash(
        start_date, end_date, datetime_to_yield_hash
      )
      [pv_date_hash_to_x48_yield_array, missing_date_times, whole_day_substitutes]
    end

    private

    # ======================= HISTORIC DATA SUPPORT METHODS ================================================
    def process_pv_data(pv_data, meta_data_dictionary, sunrise_sunset_latitude, sunrise_sunset_longitude)
      datetime_to_yield_hash = convert_raw_data(pv_data, meta_data_dictionary)
      zero_out_noise(datetime_to_yield_hash, sunrise_sunset_latitude, sunrise_sunset_longitude)
    end

    def convert_to_date_to_x48_yield_hash(start_date, end_date, datetime_to_yield_hash)
      date_to_halfhour_yields_x48 = {}
      missing_date_times = []
      too_little_data_on_day = []
      interpolator = setup_interpolation(datetime_to_yield_hash)

      (start_date..end_date).each do |date|
        missing_on_day = 0
        days_data = []
        (0..23).each do |hour|
          [0, 30].freeze.each do |minutes|
            dt = DateTime.new(date.year, date.month, date.day, hour, minutes, 0)
            if datetime_to_yield_hash.key?(dt)
              days_data.push(datetime_to_yield_hash[dt])
            else
              missing_on_day += 1 if hour >= 6 && hour <= 18
              days_data.push(interpolator.at(dt))
              missing_date_times.push(dt)
            end
          end
        end

        if missing_on_day > 5 && date > start_date
          too_little_data_on_day.push(date)
        elsif days_data.compact.empty?
          Rails.logger.error { "No valid readings for #{date}" }
          too_little_data_on_day.push(date)
        elsif days_data.sum <= 0.0
          Rails.logger.error { "Data sums to zero on #{date}" }
          too_little_data_on_day.push(date)
        else
          date_to_halfhour_yields_x48[date] = days_data
        end
      end

      whole_day_substitutes = substitute_missing_days(too_little_data_on_day, date_to_halfhour_yields_x48, start_date,
                                                      end_date)

      date_to_halfhour_yields_x48 = date_to_halfhour_yields_x48.sort.to_h

      [date_to_halfhour_yields_x48, missing_date_times, whole_day_substitutes]
    end

    def substitute_missing_days(missing_days, data, start_date, end_date)
      substitute_days = {}
      missing_days.each do |missing_date|
        (start_date..(missing_date - 1)).reverse_each do |search_date|
          if !substitute_days.key?(missing_date) && data.key?(search_date)
            substitute_days[missing_date] =
              search_date
          end
        end
        ((missing_date + 1)..end_date).each do |search_date|
          if !substitute_days.key?(missing_date) && data.key?(search_date)
            substitute_days[missing_date] =
              search_date
          end
        end
      end
      substitute_days.each do |missing_date, substitute_date|
        data[missing_date] = data[substitute_date]
      end
      substitute_days
    end

    def setup_interpolation(datetime_to_yield_hash)
      integer_keyed_data = datetime_to_yield_hash.transform_keys { |t| t.to_time.to_i }
      Interpolate::Points.new(integer_keyed_data)
    end

    def zero_out_noise(datetime_to_yield_hash, latitude, longitude)
      datetime_to_yield_hash.each do |datetime, yield_pv|
        datetime_to_yield_hash[datetime] = 0.0 unless daytime?(datetime, latitude, longitude, -0.5)
        datetime_to_yield_hash[datetime] = 0.0 if yield_pv < @yield_diff_criteria
      end
      datetime_to_yield_hash
    end

    # check for sunrise (margin = hours after sunrise, before sunset test applied)
    def daytime?(datetime, latitude, longitude, margin_hours)
      sr_criteria, ss_criteria = Utilities::SunTimes.criteria(datetime, latitude, longitude, margin_hours)
      sr_criteria_dt = DateTime.parse(sr_criteria.to_s) # crudely convert to datetime, avoid time as very slow on Windows
      ss_criteria_dt = DateTime.parse(ss_criteria.to_s) # crudely convert to datetime, avoid time as very slow on Windows
      datetime > sr_criteria_dt && datetime < ss_criteria_dt
    end

    def convert_raw_data(pv_data, meta_data_dictionary)
      all_pv_yield = {}
      pv_data.each do |halfhour_data|
        dts = halfhour_data[meta_data_dictionary.index('datetime_gmt')]
        gmt_time = DateTime.parse(dts)
        time = adjust_to_bst(gmt_time)
        generation = halfhour_data[meta_data_dictionary.index('generation_mw')]
        capacity = halfhour_data[meta_data_dictionary.index('installedcapacity_mwp')]
        next if generation.nil? || capacity.nil? || capacity.zero?

        yield_pv = generation / capacity
        all_pv_yield[time] = yield_pv
      end
      all_pv_yield
    end

    # silently deal with the case of the Autumn time zone change where the local time
    # around midnight exists twice - in this case just use the UTC time;
    # the same issue occurs in Spring where an hour of local time doesn't exist
    # in both cases given it is dark it doesn't matter
    # and the numbers are relatively constant, this is 'ok'
    def adjust_to_bst(datetime)
      @schools_timezone.utc_to_local(datetime)
    rescue TZInfo::AmbiguousTime, TZInfo::PeriodNotFound => _e
      datetime
    end

    def download_historic_data(gsp_id, start_date, end_date)
      pv_data = []
      meta_data_dictionary = nil
      # split request into chunks of 20 to avoid timeout for too big a request
      (start_date..end_date).to_a.each_slice(20).to_a.each do |dates|
        raw_data = @pv_live_api.gsp(gsp_id, dates.first, dates.last)
        pv_data += raw_data[:data]
        meta_data_dictionary = raw_data[:meta]
      end
      [pv_data, meta_data_dictionary]
    end

    def decode_areas(areas, meta)
      areas.map do |area|
        {
          gsp_id: area[meta.index('gsp_id')],
          gsp_name: area[meta.index('gsp_name')],
          pes_id: area[meta.index('pes_id')]
        }
      end
    end
  end
end
