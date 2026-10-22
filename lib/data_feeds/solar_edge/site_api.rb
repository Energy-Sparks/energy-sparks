# frozen_string_literal: true

module DataFeeds
  module SolarEdge
    # rubocop:disable-next Metrics/ClassLength
    class SiteApi < Base
      MAX_QUARTER_HOUR_PERIOD = 12.hours

      # Usage tier is 25 CPM.
      RETRY_OPTIONS = {
        retry_statuses: [429],
        max: 5,
        interval: 2.5,
        interval_randomness: 0.5,
        backoff_factor: 2
      }.freeze

      def initialize(site_id:, access_token:, stubs: nil)
        @site_id = site_id
        @access_token = access_token
        @connection = build_connection(
          url: "#{API_BASE}/sites/#{@site_id}",
          headers: auth_headers,
          retry_options: RETRY_OPTIONS,
          stubs: stubs
        )
      end

      def details
        @connection.get('').body
      end

      def inventory(types: 'METER')
        @connection.get('devices', { types: }).body
      end

      def energy(resolution: 'QUARTER_HOUR', unit: 'KWH', from: nil, to: nil)
        params = add_from_to(params: { resolution:, unit: }, from:, to:)
        @connection.get('energy', params).body
      end

      # rubocop:disable-next Metrics/ParameterLists
      def meter_measurement(serial_number:, measurement: 'import-energy', resolution: 'QUARTER_HOUR', unit: 'KWH',
                            from: nil, to: nil)
        params = add_from_to(params: { resolution:, unit: }, from:, to:)
        @connection.get("meters/#{serial_number}/#{measurement}", params).body
      end

      # Only way to request period of data available in v2 is to ask for total
      # energy production since installation date (or a very early date)
      def date_range
        @date_range ||= begin
          total_energy = energy(resolution: 'TOTAL', from: DateTime.new(2000))
          {
            from: DateTime.parse(total_energy['period']['from']),
            to: DateTime.parse(total_energy['period']['to'])
          }
        end
      end

      def production(start_date: nil, end_date: nil)
        readings = []
        windowed_request(start_date, end_date) do |from, to|
          response = energy(from:, to:)
          readings.concat(response.fetch('values'))
        end
        quarter_hourly_to_half_hourly(readings)
      end

      def import_energy(serial_number:, start_date: nil, end_date: nil)
        readings = []
        windowed_request(start_date, end_date) do |from, to|
          response = meter_measurement(serial_number:, from:, to:)
          readings.concat(response.fetch('values'))
        end
        quarter_hourly_to_half_hourly(readings)
      end

      def export_energy(serial_number:, start_date: nil, end_date: nil)
        readings = []
        windowed_request(start_date, end_date) do |from, to|
          response = meter_measurement(serial_number:, measurement: 'export-energy', from:, to:)
          readings.concat(response.fetch('values'))
        end
        quarter_hourly_to_half_hourly(readings)
      end

      private

      def windowed_request(requested_start_date, requested_end_date, window_size: MAX_QUARTER_HOUR_PERIOD)
        start_date, end_date = request_period(requested_start_date, requested_end_date)
        from = midnight_in_europe_london(start_date)
        to   = midnight_in_europe_london(end_date + 1.day)

        while from < to
          window_end = [from + window_size, to].min

          yield(from, window_end)

          from = window_end
        end
      end

      def midnight_in_europe_london(date)
        date.in_time_zone('Europe/London').beginning_of_day
      end

      def request_period(start_date, end_date)
        return start_date, end_date if start_date && end_date

        dates = date_range

        [start_date || dates[:from].to_date, end_date || dates[:to].to_date]
      end

      def add_from_to(params:, from:, to:)
        params[:from] = from.in_time_zone('Europe/London').iso8601 if from
        params[:to] = to.in_time_zone('Europe/London').iso8601 if to
        params
      end

      # Convert array of readings in 15 minute intervals to a hash of  Date => Array(48) readings
      def quarter_hourly_to_half_hourly(readings)
        readings.each_with_object(date_to_x48_hash) do |reading, result|
          timestamp = Time.iso8601(reading.fetch('timestamp'))
          index = timestamp_to_hh_index(timestamp)

          result[timestamp.to_date][index] = add_nillable(result[timestamp.to_date][index], reading['value'])
        end
      end

      def timestamp_to_hh_index(timestamp)
        (timestamp.hour * 2) + (timestamp.min / 30)
      end

      def add_nillable(first, second)
        return second if first.nil?
        return first if second.nil?

        first + second
      end

      def date_to_x48_hash
        Hash.new { |h, k| h[k] = Array.new(48, nil) }
      end

      def auth_headers
        { 'Authorization' => "Bearer #{@access_token}" }
      end
    end
  end
end
