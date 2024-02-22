module DataFeeds
  module N3rgy
    class ApiFailure < StandardError; end
    class NotFound < StandardError; end
    class NotAllowed < StandardError; end
    class NotAuthorised < StandardError; end

    class DataApiClient < BaseClient
      def initialize(api_key: ENV['N3RGY_SANDBOX_API_KEY'],
                     base_url: ENV['N3RGY_SANDBOX_CONSENT_URL_V2'],
                     connection: nil)
        @api_key = api_key
        @base_url = base_url
        @connection = connection
      end

      def self.production_client
        DataApiClient.new(api_key: ENV['N3RGY_API_KEY'], base_url: ENV['N3RGY_DATA_URL_V2'])
      end

      def list_consented_meters(start_at: 0, max_results: 100)
        get_data('/', { 'startAt': start_at, 'maxResults': max_results })
      end

      private

      def get_data(url)
        response = connection.get(url)
        raise NotAuthorised.new(error_message(response)) if response.status == 401
        raise NotAllowed.new(error_message(response)) if response.status == 403
        raise NotFound.new(error_message(response)) if response.status == 404
        raise ApiFailure.new(error_message(response)) unless response.success?
        JSON.parse(response.body)
      end
    end
  end
end
