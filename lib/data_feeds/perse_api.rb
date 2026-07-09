# frozen_string_literal: true

module DataFeeds
  class PerseApi
    extend Limiter::Mixin

    def initialize
      @connection = FaradayHelper.connection(url: ENV.fetch('PERSE_API_URL'),
                                             # should this be an Accept rather than content-type header?
                                             headers: { content_type: 'application/json',
                                                        'api_key' => ENV.fetch('PERSE_API_KEY') },
                                             # don't retry due to limit below?
                                             retry_options: nil) do |f|
        f.request :json
        f.response :json
      end
    end

    limit_method :meter_history_realtime_data, rate: 120 # not sure on actual limit - trying 120 per 60 seconds
    def meter_history_realtime_data(mpan, from_date)
      params = { MPAN: mpan, fromDate: from_date.respond_to?(:strftime) ? from_date.strftime('%Y-%m-%d') : from_date }
      @connection.get('/meterhistory/v2/realtime-data', params).body
    end
  end
end
