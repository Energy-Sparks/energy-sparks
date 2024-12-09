# frozen_string_literal: true

module DataFeeds
  module PerseApi
    def self.connection
      Faraday.new(ENV.fetch('PERSE_API_URL'), headers: { content_type: 'application/json',
                                                         'api_key' => ENV.fetch('PERSE_API_KEY') }) do |f|
        f.response :json
        # f.response :logger
      end
    end

    def self.meter_history_realtime_data(mpan, from_date)
      connection.get('/meterhistory/v2/realtime-data',
                     { MPAN: mpan, fromDate: from_date.strftime('%Y-%m-%d') }).body
    end
  end
end
