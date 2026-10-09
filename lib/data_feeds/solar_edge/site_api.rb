# frozen_string_literal: true

module DataFeeds
  module SolarEdge
    # rubocop:disable-next Metrics/ClassLength
    class SiteApi < Base
      MAX_QUARTER_HOUR_PERIOD = 7 # days according to API response, although docs say 12 hours.

      def initialize(site_id:, access_token:, stubs: nil)
        @site_id = site_id
        @access_token = access_token
        @connection = FaradayHelper.connection(url: "#{API_BASE}/sites/#{@site_id}",
                                               headers: auth_headers,
                                               retry_options: { retry_statuses: [429] }) do |f|
          f.adapter(:test, stubs) if stubs
          f.response :json
        end
      end

      def details
        @connection.get('').body
      end

      # "ACTIVE" indicates that the inverter has communicated with the Monitoring Platform at least once.
      # "PENDING" indicates it has never communicated.
      def status
        details['activationStatus']
      end

      def active?
        status == 'ACTIVE'
      end

      def inventory(types: 'METER')
        @connection.get('devices', { types: }).body
      end

      def energy(resolution: 'QUARTER_HOUR', unit: 'KWH', from: nil, to: nil)
        params = add_from_to(params: { resolution:, unit: }, from:, to:)
        @connection.get('energy', params).body
      end

      # Only way to request period of data available in v2 is to ask for total
      # energy production since installation date (or a very early date)
      def date_range
        total_energy = energy(resolution: 'TOTAL', from: DateTime.new(2000))
        {
          from: DateTime.parse(total_energy['period']['from']),
          to: DateTime.parse(total_energy['period']['to'])
        }
      end

      # NOTE: does not support unit parameter so returns data in Wh.
      def meters_telemetry(resolution: 'QUARTER_HOUR', from: nil, to: nil)
        params = add_from_to(params: { resolution: }, from:, to:)
        @connection.get('meters/telemetry', params).body
      end

      def production(start_date: nil, end_date: nil)
        readings = []
        windowed_request(start_date, end_date, MAX_QUARTER_HOUR_PERIOD) do |from, to|
          response = energy(from:, to:)
          readings.concat(response.fetch('values'))
        end
        quarter_hourly_to_half_hourly(readings)
      end

      def import_and_export(start_date: nil, end_date: nil)
        import_and_export = {
          exported_solar_pv: [],
          electricity: []
        }
        windowed_request(start_date, end_date, MAX_QUARTER_HOUR_PERIOD) do |from, to|
          readings = meters_telemetry(from:, to:)
          _, meter_data = readings.fetch('meters').sole
          import_and_export[:exported_solar_pv] += telemetry_for(meter_data, 'exportEnergy')
          import_and_export[:electricity] += telemetry_for(meter_data, 'importEnergy')
        end
        import_and_export.transform_values { |readings| quarter_hourly_to_half_hourly(readings) }
      end

      # Backwards compatible with v1 client
      def smart_meter_data(start_date: nil, end_date: nil)
        import_and_export = import_and_export(start_date:, end_date:)
        {
          solar_pv: { readings: production(start_date:, end_date:) },
          electricity: { readings: import_and_export[:electricity] },
          exported_solar_pv: { readings: import_and_export[:exported_solar_pv] }
        }
      end

      private

      def telemetry_for(meter_data, meter_type)
        wh_to_kwh(meter_data.fetch(meter_type).fetch('values'))
      end

      def windowed_request(start_date, end_date, slice)
        request_period(start_date, end_date).each_slice(slice) do |window|
          yield(midnight_in_europe_london(window.first),
                midnight_in_europe_london(window.last + 1.day))
        end
      end

      def midnight_in_europe_london(date)
        date.in_time_zone('Europe/London').beginning_of_day
      end

      def request_period(start_date, end_date)
        (start_date..end_date) if start_date && end_date

        dates = date_range
        (start_date || dates[:from].to_date)..(end_date || dates[:to].to_date)
      end

      def add_from_to(params:, from:, to:)
        params[:from] = from.in_time_zone('Europe/London').iso8601 if from
        params[:to] = to.in_time_zone('Europe/London').iso8601 if to
        params
      end

      # Convert array of { timestamp:, value: } with values in Wh to kWh
      def wh_to_kwh(readings)
        readings.map { |reading| reading.merge('value' => reading['value']&./(1000.0)) }
      end

      # Convert array of readings in 15 minute intervals to a hash of  Date => Array(48) readings
      def quarter_hourly_to_half_hourly(readings)
        readings.each_with_object(date_to_x48_hash) do |reading, result|
          timestamp = Time.iso8601(reading.fetch('timestamp'))
          slot = (timestamp.hour * 2) + (timestamp.min / 30)

          result[timestamp.to_date][slot] += reading['value'].to_f
        end
      end

      def date_to_x48_hash
        Hash.new { |h, k| h[k] = Array.new(48, 0.0) }
      end

      def auth_headers
        { 'Authorization' => "Bearer #{@access_token}" }
      end
    end
  end
end
