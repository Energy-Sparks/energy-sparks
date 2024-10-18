# frozen_string_literal: true

# provides access to Low Carbon Hub's schools solar pv meter data via Rbee API
#
# Note: from API manual:
#
#   The meters log on twice a day between 00:00 and 02:00am UTC+0, and between 12:00 and
#   02:00pm UTC+0. Solar radiation data are updated between 02:00 and 03:00am UTC+0. We
#   kindly ask you NOT TO MAKE REQUESTS ON THE WEBSERVICE DURING THESE TIME FRAMES . You
#   would also take the risk to receive incomplete data.
#
#   PH: the RbeeSolarPV class constuctor will raise an exception if run between these times
#
# optimum cron job time about 05:00am ish?
#
# note Rbee for historical reasons returns data in different timezones depending on which
# service you call smart_meter_data() interface converts back from UTC time to local time
# so the user's charts always look as though they are in local time i.e. the school opens
# at 08:00 whether its summer or winter
#
# the exported data has is negated inline with Energy Spark's convention that exported kWh is -tve
#
require 'digest'
require 'net/http'
require 'json'
require 'tzinfo'

module DataFeeds
  class RbeeSolarPV
    class InvalidComponent < StandardError; end
    COMPONENTS = %w[prod in1 out1 in2].freeze

    METER_TYPES = %i[solar_pv electricity exported_solar_pv].freeze

    def initialize(username = ENV.fetch('ENERGYSPARKSRBEEUSERNAME', nil),
                   password = ENV.fetch('ENERGYSPARKSRBEEPASSWORD', nil))
      @username = username
      @password = password
      now = Time.now.utc
      @schools_timezone = TZInfo::Timezone.get('Europe/London')
      if now.hour.between?(
        0, 2
      ) || now.hour.between?(12, 13)
        raise EnergySparksUnexpectedStateException.new,
              'Download should only be run outside 00:00 to 03:00 UTC+0 and 12:00 and 01:00 UTC+0'
      end
    end

    def available_meter_ids(datetime = Time.now.utc)
      data = get_service('listDevices', datetime)
      data['list'].map(&:to_i)
    end

    def first_connection_date(meter_id)
      Date.parse(configuration(meter_id)['firstConnectionDate'])
    end

    def last_connection_date(meter_id)
      Date.parse(configuration(meter_id)['lastConnectionDate'])
    end

    def peak_power(meter_id)
      configuration(meter_id)['peakPower']
    end

    def kwh_cost(meter_id)
      configuration(meter_id)['kwhCost']
    end

    def configuration(meter_id)
      @configuration ||= meter_configuration(meter_id)
    end

    def meter_configuration(meter_id, datetime = Time.now.utc)
      url = service_url('getDeviceInfo', datetime) + "&serialNumber=#{meter_id}"
      get_data(url)
    end

    def full_installation_information(meter_id, datetime = Time.now.utc)
      url = service_url('getInstallationInfo', datetime) + "&serialNumber=#{meter_id}"
      get_data(url)
    end

    # returns { readings: dates[date] = kwhz48, missing_readings: [datetimes] }
    # avoid using this interface which is a subsiary interface to smart_meter_data()
    # the date times returned by Rbee for this interface are local time e.g. GMT/BST and not UTC(+0)
    def solar_pv_readings(meter_id, start_date, end_date, datetime = Time.now.utc)
      data = {}
      (start_date..end_date).each_slice(7) do |seven_days| # api limit of 7 days
        data = data.deep_merge(solar_pv_readings_7_days(meter_id, seven_days.first, seven_days.last, datetime))
      end
      data
    end

    # main meter reading interface: set start_date to nil if calling first time
    # picks up first meter reading date
    # all the raw data returned by Rbee is in UTC(+0)
    # gets data in 6 day + 1 hour chunks, as opposed to API limit of 7 days,
    # as margin of 1 hour required for UTC to BST/GMT conversion
    def smart_meter_data(meter_id, start_date, end_date)
      data = {}
      unless start_date.is_a?(Date) && end_date.is_a?(Date)
        raise EnergySparksUnexpectedStateException.new,
              'Expecting start_date, end_time to be of class Date'
      end

      (start_date..end_date).each_slice(6) do |six_days|
        data = data.deep_merge(smart_meter_data_6_days(meter_id, six_days.first, six_days.last, Time.now.utc))
      end
      data
    end

    # aggregates underlying smart metering data by type 'prod', in1', 'out1'
    # in order to understand meter setup for Newport schools where
    # the inventory/full information call doesn't provide information about the underlying
    # metering
    def smart_meter_data_analysis(meter_id, start_date, end_date)
      totals = {}
      start_date = first_connection_date(meter_id) if start_date.nil?
      unless start_date.is_a?(Date) && end_date.is_a?(Date)
        raise EnergySparksUnexpectedStateException.new,
              'Expecting start_date, end_time to be of class Date'
      end

      (start_date..end_date).each_slice(6) do |six_days|
        data = smart_meter_data_6_days_debug(meter_id, six_days.first, six_days.last, Time.now.utc)
        data.each do |type, value|
          totals[type] ||= 0.0
          totals[type] += value.to_f
        end
      end
      totals
    end

    def smart_meter_data_by_component(meter_id, start_date, end_date, component = nil)
      raise InvalidComponent, "Component = #{component}" unless COMPONENTS.include?(component)

      data = {}
      unless start_date.is_a?(Date) && end_date.is_a?(Date)
        raise EnergySparksUnexpectedStateException.new,
              'Expecting start_date, end_time to be of class Date'
      end

      (start_date..end_date).each_slice(6) do |six_days|
        data = data.deep_merge(smart_meter_data_6_days_by_component(meter_id, component, six_days.first, six_days.last,
                                                                    Time.now.utc))
      end
      data
    end

    def ping(datetime = Time.now.utc)
      get_service('ping', datetime)
    end

    private

    def get_service(service, datetime)
      url = service_url(service, datetime)
      get_data(url)
    end

    def solar_pv_readings_7_days(meter_id, start_date, end_date, datetime)
      url = meter_readings_url('getDeviceProduction', meter_id, start_date, end_date + 1, datetime)
      raw_data = get_data(url)
      data = process_raw_data(raw_data, 'measure', start_date, end_date, false)
      { solar_pv: data }
    end

    def smart_meter_data_6_days(meter_id, start_date, end_date, datetime)
      start_date_minus_1_hour = extra_hour_for_british_summer_time(start_date)
      url = meter_readings_url('getDeviceSmartData', meter_id, start_date_minus_1_hour, end_date + 1, datetime)
      raw_data = get_data(url)
      {
        solar_pv: process_raw_data(raw_data, 'prod', start_date, end_date, true),
        electricity: process_raw_data(raw_data, 'in1', start_date, end_date, true),
        exported_solar_pv: process_raw_data(raw_data, 'out1', start_date, end_date, true, true)
      }
    end

    def smart_meter_data_6_days_by_component(meter_id, component, start_date, end_date, datetime)
      start_date_minus_1_hour = extra_hour_for_british_summer_time(start_date)
      url = meter_readings_url('getDeviceSmartData', meter_id, start_date_minus_1_hour, end_date + 1, datetime)
      raw_data = get_data(url)
      process_raw_data(raw_data, component, start_date, end_date, true)
    end

    def smart_meter_data_6_days_analysis(meter_id, start_date, end_date, datetime)
      start_date_minus_1_hour = extra_hour_for_british_summer_time(start_date)
      url = meter_readings_url('getDeviceSmartData', meter_id, start_date_minus_1_hour, end_date + 1, datetime)
      raw_data = get_data(url)
      results = {}
      raw_data['records'].each do |record|
        record.each do |type, value|
          next if type == 'measureDate'
          next if value.to_f == -1

          results[type] ||= 0.0
          results[type] += value.to_f / 1000.0
        end
      end
      results
    end

    # to cope with BST, add an hour's extra data at the beginning of the data request
    # this allows us to provide correct 'local time' data from the RBee provided UTC data
    # e.g. if start date was 30 Mar 2019, and we wanted the reading for 00:30, we would need
    # to lookup the ZBee UTC data from 23:30 29 Mar 2019 UTC, this only applies to the smart meter
    # interface and not the solar pv interface where the Rbee data is in local time
    # for simplicity always ask for the extra hour's data, even if its not needed in the winter
    def extra_hour_for_british_summer_time(start_date)
      t = Time.zone.local(start_date.year, start_date.month, start_date.day, 0, 0, 0)
      t -= 60 * 60
      t # propogate this as a Time rather than a DateTime just in case there is a rounding issue
    end

    def process_raw_data(raw_data, key, start_date, end_date, adjust_to_bst, negate_data = false)
      multiplier = negate_data ? -1.0 : 1.0
      # -1 seems to signify a missing reading, although there is an ambiguity around this TODO(PH, 14Aug2019) ask RBee
      readings_with_missing_removed = raw_data['records'].delete_if { |reading| reading[key] == -1 }
      # / 1000.0 => convert from RBee Wh to Energy Sparks kWh
      readings = readings_with_missing_removed.to_h do |reading|
        [DateTime.parse(reading['measureDate']), multiplier * reading[key].to_f / 1000.0]
      end
      convert_ten_minute_readings_to_date_to_x48(readings, start_date, end_date, adjust_to_bst)
    end

    def convert_ten_minute_readings_to_date_to_x48(raw_data, start_date, end_date, adjust_to_bst)
      missing_readings = []
      readings = Hash.new { |h, k| h[k] = Array.new(48, 0.0) }

      # iterate through data at fixed time intervals
      # so missing date times can be spotted
      (start_date..end_date).each do |date|
        (0..23).each do |hour|
          [0, 30].freeze.each_with_index do |mins30, hh_index|
            [0, 10, 20].freeze.each do |mins10|
              dt = datetime_to_10_minutes(date, hour, mins30 + mins10)
              dt = adjust_to_bst(dt) if adjust_to_bst # raw data in UTC, convert to local time
              if raw_data.key?(dt)
                readings[date][(hour * 2) + hh_index] += raw_data[dt]
              else
                missing_readings.push(dt)
              end
            end
          end
        end
      end
      {
        readings:,
        missing_readings:
      }
    end

    # silently deal with the case of the Autumn time zone change where the local time
    # around midnight exists twice - in this case just use the UTC time;
    # the same issue occurs in Spring where an hour of local time doesn't exist
    # in both cases given this is overnight baseload
    # and the numbers are relatively constant, this is 'ok'
    def adjust_to_bst(datetime)
      @schools_timezone.utc_to_local(datetime)
    rescue TZInfo::AmbiguousTime, TZInfo::PeriodNotFound => _e
      datetime
    end

    def datetime_to_10_minutes(date, hour, mins)
      dt = DateTime.new(date.year, date.month, date.day, hour, mins, 0)
      #  + 10 minutes added to end as the datetime for the bucket is the end time of the bucket
      # i.e. the 00:00 to 00:30 output is these 3 buckets 00:10, 00:20, 00:30
      t = dt.to_time + (10 * 60) # use Time to avoid potential Date rounding errors
      DateTime.new(t.year, t.month, t.day, t.hour, t.min, t.sec)
    end

    def get_data(url)
      uri = URI(url)
      response = Net::HTTP.get(uri)
      data = JSON.parse(response)
      raise EnergySparksBadDataException, data['message'] if data['httpStatus'] && data['httpStatus'] >= 400

      data
    end

    def service_url(service, datetime)
      mps_key = mps(@username, @password, datetime)
      "https://pvmeter.com/solar/webservices/#{service}?login=#{@username}&mps=#{mps_key}&requestDate=#{format_datetime(
        datetime, '%3A'
      )}"
    end

    def meter_readings_url(service, meter_id, start_date, end_date, datetime = Time.now.utc)
      service_url(service, datetime) +
        "&serialNumber=#{meter_id}&" +
        ten_minute_meter_reading_interval_url(start_date, end_date)
    end

    def ten_minute_meter_reading_interval_url(start_date, end_date)
      days = end_date.to_date - start_date.to_date
      if days > 7
        raise EnergySparksUnexpectedStateException.new,
              "too many days #{days} requested, API limits to 7"
      end

      "&startDate=#{format_datetime(start_date)}&endDate=#{format_datetime(end_date)}&step=tenmin"
    end

    # see API manual - salted hash of password, user name and date - conforms to New API (issued 12Aug2019)
    def mps(username, password, datetime)
      salted_password = "#{password}{#{username}}"
      hashed_password = Digest::SHA512.hexdigest(salted_password).downcase
      Digest::SHA1.hexdigest(hashed_password + format_datetime(datetime))
    end

    def format_datetime(datetime, replace_colons = ':')
      datetime.strftime('%Y-%m-%dT%H:%M:%S').gsub(':', replace_colons)
    end
  end
end
