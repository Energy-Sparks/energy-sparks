module DataFeeds
  module N3rgy
    class ConsentFailure < StandardError; end

    class ConsentApiClient < BaseClient
      def initialize(api_key: ENV['N3RGY_SANDBOX_API_KEY'],
                     base_url: ENV['N3RGY_SANDBOX_CONSENT_URL_V2'],
                     connection: nil)
        @api_key = api_key
        @base_url = base_url
        @connection = http_connection(connection)
      end

      def self.production_client
        ConsentApiClient.new(api_key: ENV['N3RGY_API_KEY'], base_url: ENV['N3RGY_CONSENT_URL_V2'])
      end

      def add_trusted_consent(mpxn, reference, move_in_date = '2012-01-01')
        url = 'consents/add-trusted-consent'
        config = {
          'mpxn'        => mpxn.to_s,
          'evidence'    => reference,
          'moveInDate'  => move_in_date
        }
        response = @connection.post(url) do |req|
          req.body = config.to_json
        end
        raise ConsentFailure, error_message(response) unless response.success?
        true
      end

      def withdraw_consent(mpxn)
        url = "consents/withdraw-consent/#{mpxn}"

        response = @connection.delete(url)
        raise ConsentFailure.new(error_message(response)) unless response.success?
        true
      end
    end
  end
end
