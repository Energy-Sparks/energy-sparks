# frozen_string_literal: true

module DataFeeds
  module PerseApi
    def self.connection
      Faraday.new(ENV.fetch('PERSE_API_URL'), headers: { content_type: 'application/json',
                                                         'api_key' => ENV.fetch('PERSE_API_KEY') }) do |f|
        f.response :json
        f.response :raise_error
        # f.response :logger
      end
    end

    def self.meter_history_realtime_data(mpan, from_date)
      params = { MPAN: mpan, fromDate: from_date.strftime('%Y-%m-%d') }
      connection.get('/meterhistory/v2/realtime-data', params).body
    rescue Faraday::Error => e
      EnergySparks::Log.exception(e, mpan:, from_date:, status: e&.response_status, body: e&.response_body)
      {}
    end

    def self.meter_readings(mpan, from_date)
      data_to_import = meter_history_realtime_data(mpan, from_date)['data']&.select do |data|
        data['MeasurementQuantity'] == 'AI' && (1..48).map { |i| "UT#{i}" }.all? { |key| data[key] == 'A' }
      end
      data_to_import.map do |data|
        readings = (1..48).map { |i| "P#{i}" }.map { |key| data[key] }
        [Date.parse(data['Date']), readings.map(&:to_f)]
      end
    end
  end
end
