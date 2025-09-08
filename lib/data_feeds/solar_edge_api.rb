# frozen_string_literal: true

# Basic client for the Solar Edge Solar PV API
#
# Handles both requests to the Solar Edge API and reformatting the
# results to manage Energy Sparks expectations
module DataFeeds
  class SolarEdgeApi
    class ApiFailure < StandardError; end
    class NotFound < StandardError; end
    class NotAllowed < StandardError; end
    class NotAuthorised < StandardError; end

    BASE_URL = 'https://monitoringapi.solaredge.com'
    # Maximum number of days that can be requested for 15 minute period data
    # API docs say "one month"
    MAX_WINDOW_SIZE = 25
    def initialize(api_key = ENV.fetch('ENERGYSPARKSSOLAREDGEAPIKEY', nil))
      @api_key = api_key
    end

    def site_details
      @site_details ||= get_data('/sites/list')
    end

    def site_ids
      sites.pluck('id')
    end

    def sites
      site_details['sites']['site']
    end

    def site_start_end_dates(site_id)
      dates = get_data("/site/#{site_id}/dataPeriod")
      [Date.parse(dates['dataPeriod']['startDate']), Date.parse(dates['dataPeriod']['endDate'])]
    end

    # Used by application code
    # nil date will find max and min dates, so nil, nil => all data
    def smart_meter_data(meter_id, start_date, end_date)
      start_date, end_date = dates(meter_id, start_date, end_date)

      raw_data =  raw_meter_readings(meter_id, start_date, end_date)

      processed_meter_data = select_wanted_data_and_convert_keys(raw_data)

      convert_to_meter_type_to_date_to_kwh_x48(processed_meter_data, start_date, end_date)
    end

    # Unused?
    def solar_pv_readings(meter_id, start_date, end_date)
      start_date, end_date = dates(meter_id, start_date, end_date)

      raw_data = raw_production_meter_readings(meter_id, start_date, end_date)

      dt_to_kwh = raw_data.to_h { |h| [date(h['date']), (h['value'] || 0.0) / 1000.0] }

      convert_to_date_to_kwh_x48(dt_to_kwh, start_date, end_date)
    end

    private

    def convert_to_date_to_kwh_x48(dt_to_kwh, start_date, end_date)
      missing_readings = []
      readings = Hash.new { |h, k| h[k] = Array.new(48, 0.0) }

      (start_date..end_date).each do |date|
        (0..23).each do |hour|
          [0, 30].freeze.each_with_index do |mins30, hh_index|
            [0, 15].freeze.each do |mins15|
              dt = datetime_to_15_minutes(date, hour, mins30 + mins15)
              if dt_to_kwh.key?(dt)
                readings[date][(hour * 2) + hh_index] += dt_to_kwh[dt]
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

    def datetime_to_15_minutes(date, hour, mins)
      dt = DateTime.new(date.year, date.month, date.day, hour, mins, 0)
      t = dt.to_time + 0
      DateTime.new(t.year, t.month, t.day, t.hour, t.min, t.sec)
    end

    def date(date_string)
      DateTime.parse(date_string)
    end

    def convert_to_meter_type_to_date_to_kwh_x48(processed_meter_data, start_date, end_date)
      converted = {}
      processed_meter_data.map do |meter_type, dt_to_kwh|
        converted[meter_type] = convert_to_date_to_kwh_x48(dt_to_kwh, start_date, end_date) unless dt_to_kwh.nil?
      end
      converted
    end

    def raw_meter_readings(meter_id, start_date, end_date)
      data = {}
      (start_date..end_date).each_slice(MAX_WINDOW_SIZE) do |window| # api limit of 1 month
        raw_data = raw_meter_readings_windowed(meter_id, window.first, window.last)
        converted_data = convert_raw_meter_data(raw_data)
        converted_data.each do |solar_edge_key, values|
          data[solar_edge_key] ||= {}
          data[solar_edge_key].merge!(values)
        end
      end
      data
    end

    def raw_meter_readings_windowed(meter_id, start_date, end_date)
      params = {
        timeUnit: 'QUARTER_OF_AN_HOUR',
        startTime: solar_edge_url_time(start_date),
        endTime: solar_edge_url_time(end_date + 1)
      }.merge(default_params)
      get_data("/site/#{meter_id}/energyDetails", params)
    end

    def raw_production_meter_readings(meter_id, start_date, end_date)
      data = []
      (start_date..end_date).each_slice(MAX_WINDOW_SIZE) do |window| # api limit of 1 month
        data.push(raw_production_meter_readings_windowed(meter_id, window.first, window.last))
      end
      data.flatten
    end

    def raw_production_meter_readings_windowed(meter_id, start_date, end_date)
      params = {
        timeUnit: 'QUARTER_OF_AN_HOUR',
        startDate: start_date,
        endDate: end_date
      }.merge(default_params)
      get_data("/site/#{meter_id}/energy", params)['energy']['values']
    end

    def convert_raw_meter_data(raw_data)
      raw_data['energyDetails']['meters'].to_h do |meter|
        [
          meter['type'],
          process_raw_values(meter['values'])
        ]
      end
    end

    def solar_edge_meter_type_map
      {
        'Production' => :solar_pv,
        'Consumption' => :electricity,
        'SelfConsumption' => nil,
        'FeedIn' => :exported_solar_pv,
        'Purchased' => nil # seems to be 'Consumption' + 'SelfConsumption'
      }
    end

    def select_wanted_data_and_convert_keys(processed_data)
      wanted_keys = solar_edge_meter_type_map.compact

      wanted_keys.to_h do |solar_edge_key, energy_sparks_key|
        [
          energy_sparks_key,
          processed_data[solar_edge_key]
        ]
      end
    end

    def process_raw_values(raw_values)
      raw_values.to_h { |h| [date(h['date']), (h['value'] || 0.0) / 1000.0] }
    end

    def dates(meter_id, start_date, end_date)
      sd, ed = site_start_end_dates(meter_id) if start_date.nil? || end_date.nil?
      start_date = sd if start_date.nil?
      end_date   = ed if end_date.nil?
      [start_date, end_date]
    end

    def solar_edge_url_time(date)
      date.strftime('%Y-%m-%d 00:00:00')
    end

    def get_data(path, params = default_params, headers = default_headers)
      response = Faraday.get(BASE_URL + path, params, headers)
      handle_response(response)
    end

    def handle_response(response)
      raise NotAuthorised, response.body if response.status == 401
      raise NotAllowed, response.body if response.status == 403
      raise NotFound, response.body if response.status == 404
      raise ApiFailure, response.body unless response.success?

      begin
        JSON.parse(response.body)
      rescue StandardError => e
        raise ApiFailure, e.message
      end
    end

    def default_params
      {
        api_key: @api_key
      }
    end

    def default_headers
      {
        Accept: 'application/json'
      }
    end
  end
end
