# frozen_string_literal: true

module DataFeeds
  module SolarEdge
    class Base
      API_BASE = 'https://monitoringapi.solaredge.com/v2'
      CONNECT_BASE = 'https://connect.solaredge.com'
      POST_HEADERS = { 'Content-Type' => 'application/json' }.freeze

      private

      def build_connection(url:, headers: {}, retry_options: {}, stubs: nil)
        FaradayHelper.connection(
          url: url,
          headers: headers,
          retry_options: retry_options
        ) do |f|
          f.adapter(:test, stubs) if stubs
          f.response :json
        end
      end
    end
  end
end
