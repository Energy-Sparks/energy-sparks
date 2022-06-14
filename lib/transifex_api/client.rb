module TransifexApi
  class Client
    class ApiFailure < StandardError; end
    class BadRequest < StandardError; end
    class NotFound < StandardError; end
    class NotAllowed < StandardError; end
    class NotAuthorised < StandardError; end

    BASE_URL = 'https://rest.api.transifex.com/'.freeze

    def initialize(api_key, connection = nil)
      @api_key = api_key
      @connection = connection
    end

    def get_organizations
      url = 'organizations'
      get_data(url)
    end

    private

    def headers
      { 'Authorization' => "Bearer #{@api_key}" }
    end

    def connection
      @connection ||= Faraday.new(BASE_URL, headers: headers)
    end

    def get_data(url)
      response = connection.get(url)
      raise BadRequest.new(error_message(response)) if response.status == 400
      raise NotAuthorised.new(error_message(response)) if response.status == 401
      raise NotAllowed.new(error_message(response)) if response.status == 403
      raise NotFound.new(error_message(response)) if response.status == 404
      raise ApiFailure.new(error_message(response)) unless response.success?
      JSON.parse(response.body)['data']
    end

    def error_message(response)
      data = JSON.parse(response.body)
      if data['errors']
        error = data['errors'][0]
        error['title']
      else
        response.body
      end
    rescue
      #problem parsing or traversing json, return original api error
      response.body
    end
  end
end
