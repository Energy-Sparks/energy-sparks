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
      params = { MPAN: mpan, fromDate: from_date.respond_to?(:strftime) ? from_date.strftime('%Y-%m-%d') : from_date }
      connection.get('/meterhistory/v2/realtime-data', params).body
    rescue Faraday::Error => e
      EnergySparks::Log.exception(e, mpan:, from_date:, status: e&.response_status, body: e&.response_body)
      {}
    end

    def self.meter_history_readings(mpan, from_date)
      meter_history_realtime_data(mpan, from_date)['data']
        &.select { |data| data_ok(data) }
        &.map { |data| [data['Date'], (1..48).map { |i| data["P#{i}"].to_f }] } || []
    end

    def self.data_ok(data)
      data['MeasurementQuantity'] == 'AI' && (1..48).all? { |i| data["UT#{i}"] == 'A' }
    end
  end
end