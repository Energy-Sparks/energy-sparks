module DataFeeds
  module N3rgy
    class ApiFailure < StandardError; end
    class NotFound < StandardError; end
    class NotAllowed < StandardError; end
    class NotAuthorised < StandardError; end

    class DataApiClient < BaseClient
      READING_TYPE_PRODUCTION = 'production'.freeze
      READING_TYPE_CONSUMPTION = 'consumption'.freeze
      READING_TYPE_IMPORT = 'import'.freeze
      READING_TYPE_EXPORT = 'export'.freeze
      READING_TYPE_TARIFF = 'tariff'.freeze

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

      # Returns a paged list of MPxNs for which we have consent to access
      # the data. Consent is granted or withdrawn via the ConsentApiClient
      def list_consented_meters(start_at: 0, max_results: 100)
        get_data('/', { 'startAt': start_at, 'maxResults': max_results })
      end

      # Checks to see if an MPxN is known to n3rgy. E.g. is it a SMETS-2
      # meter in the DCC?
      #
      # Does not require consent to return a response
      def find_mpxn(mpxn)
        get_data("/find-mpxn/#{mpxn}")
      end

      # Retrieve the list of utilities (fuel types) for the meter.
      def utilities(mpxn)
        get_data("/mpxn/#{mpxn}")
      end

      # Retrieve the list of reading types (e.g. consumption, production) for
      # a specific utility (fuel type)
      def reading_types(mpxn, fuel_type)
        get_data("/mpxn/#{mpxn}/utility/#{fuel_type}")
      end

      # Read the n3rgy consumption for a fuel type
      def consumption(mpxn, fuel_type, start_date = nil, end_date = nil)
        readings(mpxn, fuel_type, READING_TYPE_CONSUMPTION, start_date, end_date)
      end

      # Read the n3rgy production for a fuel type
      def production(mpxn, fuel_type, start_date = nil, end_date = nil)
        readings(mpxn, fuel_type, READING_TYPE_PRODUCTION, start_date, end_date)
      end

      # Fetch readings for a given MPxn, fuel type and reading type for a specified
      # date range
      #
      # Maximum 90 day window between start and end
      #
      # If not provided then their API will return the last 24 hours of data
      def readings(mpxn, fuel_type, reading_type, start_date = nil, end_date = nil)
        params = {
          'granularity': 'halfhour',
          'outputFormat': 'json'
        }
        params['start'] = url_date(start_date) if start_date.present?
        params['end'] = url_date(end_date) if end_date.present?
        get_data("/mpxn/#{mpxn}/utility/#{fuel_type}/readingtype/#{reading_type}", params)
      end

      # Fetch some diagnostic information about one or more meters identified by
      # their MPxN, UPRN (address) or their device id
      def read_inventory(device_type, mpxns: nil, uprns: nil, device_ids: nil)
        raise if mpxns.nil? && uprns.nil? && device_ids.nil?
        body = create_inventory_body(mpxns: mpxns, uprns: uprns, device_ids: device_ids)
        response = connection.post('/read-inventory', { 'deviceType': device_type }) do |req|
          req.body = body.to_json
        end
        JSON.parse(response.body)
      end

      # This is intended to be used with a URI returned by the read_inventory call.
      #
      # That methods triggers a message to the actual meter to fetch some information
      # The URI in the response will be available for download a short time afterwards
      #
      # Initially the URL will return an error before returning a JSON document
      # once the background task as n3rgy is completed.
      def fetch_with_retry(url, retry_interval = 0, max_retries = 0)
        begin
          retries ||= 0
          sleep(retry_interval)
          get_data(url)
        rescue NotAllowed => e
          retry if (retries += 1) <= max_retries
          raise e
        end
      end

      private

      def url_date(date)
        date.strftime('%Y%m%d%H%M')
      end

      def get_data(url, params = {})
        response = connection.get(url, params)
        raise NotAuthorised.new(error_message(response)) if response.status == 401
        raise NotAllowed.new(error_message(response)) if response.status == 403
        raise NotFound.new(error_message(response)) if response.status == 404
        raise ApiFailure.new(error_message(response)) unless response.success?
        JSON.parse(response.body)
      end

      def create_inventory_body(mpxns: nil, uprns: nil, device_ids: nil)
        body = {}
        unless mpxns.nil?
          body[:mpxns] = mpxns.is_a?(Array) ? mpxns : [mpxns]
        end
        unless uprns.nil?
          body[:uprns] = uprns.is_a?(Array) ? uprns : [uprns]
        end
        unless device_ids.nil?
          body[:deviceIds] = device_ids.is_a?(Array) ? device_ids : [device_ids]
        end
        body
      end
    end
  end
end
