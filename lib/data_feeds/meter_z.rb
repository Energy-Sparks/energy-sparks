# frozen_string_literal: true

module DataFeeds
  class MeterZ
    BASE_URL = 'https://api.meterz.co.uk/v1'

    # the x-api-key header needs to be lowercase to work (believe should be case insensitive per http spec) but
    # Net::Http capitalizes by default
    # http2 (as curl uses by default) would also work as that requires all headers are lowercase
    class CustomAdapter < Faraday::Adapter::NetHttp
      private

      def create_request(env)
        request = super # a Net::HTTPGenericRequest
        def request.capitalize(name) = name
        request
      end
    end

    def initialize(api_key)
      @api_key = api_key
      @connection = FaradayHelper.connection(url: BASE_URL, headers: { 'x-api-key' => @api_key }) do |f|
        f.adapter CustomAdapter
        f.response :json
      end
    end

    def readings(organisation_id, site_id, meter_id, start)
      # readings returned from start_datetime in descending order to end_datetime so if you want the last week of
      # readings end_datetime should be set to 1 week ago
      if start.nil?
        start_datetime = Date.tomorrow.iso8601
      else
        end_datetime = start.iso8601
      end
      paginated('readings') do |last_evaluated_key|
        @connection.get("organisations/#{organisation_id}/sites/#{site_id}/meters/#{meter_id}/readings",
                        { start_datetime:, end_datetime:, last_evaluated_key:, items_per_page: 1000 }.compact)
      end
    end

    def organisations
      @connection.get('organisations').body['organisations']
    end

    def meters(organisation_id)
      paginated('meters') do |last_evaluated_key|
        @connection.get("organisations/#{organisation_id}/meters", { last_evaluated_key: }.compact)
      end
    end

    private

    def paginated(data_key)
      last_evaluated_key = nil
      data = []
      loop do
        body = yield(last_evaluated_key).body
        data.concat(body[data_key])
        break unless body['more_items_to_return']

        last_evaluated_key = body['last_evaluated_key']
      end
      data
    end
  end
end
