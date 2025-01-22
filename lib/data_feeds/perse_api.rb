# frozen_string_literal: true

module DataFeeds
  class PerseApi
    extend Limiter::Mixin

    def initialize
      @connection = Faraday.new(ENV.fetch('PERSE_API_URL'), headers: { content_type: 'application/json',
                                                                       'api_key' => ENV.fetch('PERSE_API_KEY') }) do |f|
        f.response :json
        f.response :raise_error
        f.response :logger if Rails.env.development?
        f.request(:retry, { retry_statuses: [429], interval: 0.5, backoff_factor: 2 })
      end
    end

    limit_method :meter_history_realtime_data, rate: 120 # not sure on actual limit - trying 120 per 60 seconds
    def meter_history_realtime_data(mpan, from_date)
      params = { MPAN: mpan, fromDate: from_date.respond_to?(:strftime) ? from_date.strftime('%Y-%m-%d') : from_date }
      @connection.get('/meterhistory/v2/realtime-data', params).body
    rescue Faraday::Error => e
      EnergySparks::Log.exception(e, mpan:, from_date:, status: e&.response_status, body: e&.response_body)
      {}
    end
  end
end
