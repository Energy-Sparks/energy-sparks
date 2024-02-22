module DataFeeds
  module N3rgy
    class BaseClient
      private

      def headers
        {
          'x-api-key': @api_key,
          'Content-Type': 'application/json'
        }
      end

      def connection
        @connection ||= Faraday.new(@base_url, headers: headers)
      end

      # The n3rgy API returns errors in two ways. Either
      # a JSON response with a single message key, or an
      # array of errors, one per MPXN.
      def error_message(response)
        data = JSON.parse(response.body)
        if data['errors']
          error = data['errors'].first
          error['message']
        elsif data['message']
          data['message']
        else
          response.body
        end
      rescue
        # problem parsing or traversing json, return original api error
        response.body
      end
    end
  end
end
