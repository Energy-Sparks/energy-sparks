module CapsuleCrm
  # other unexpected errors
  class ApiFailure < StandardError; end
  # 401 invalid api key
  class NotAuthorised < ApiFailure; end
  # 403 operation not permitted
  class NotAllowed < ApiFailure; end
  # 400 incorrect request body
  class BadRequest < ApiFailure; end
  # 422 field validation failed
  class ValidationFailed < ApiFailure; end

  class Client
    BASE_URL = 'https://api.capsulecrm.com/api/v2'.freeze

    def initialize(api_key: ENV['CAPSULECRM_API_KEY'], connection: nil)
      @api_key = api_key
      @connection = connection || Faraday.new(BASE_URL, headers: headers)
    end

    def users
      get_data('/users')
    end

    def create_party(party)
      post_data('/parties', party)
    end

    def create_opportunity(opportunity)
      post_data('/opportunities', opportunity)
    end

    private

    def get_data(path, params = nil)
      response = @connection.get("#{BASE_URL}#{path}", params)
      return JSON.parse(response.body) if response.success?
      handle_error(response)
    end

    def post_data(path, body)
      response = @connection.post("#{BASE_URL}#{path}", JSON.generate(body))
      return JSON.parse(response.body) if response.success?
      handle_error(response)
    end

    def handle_error(response)
      raise BadRequest.new(error_message(response)) if response.status == 400
      raise NotAuthorised.new(error_message(response)) if response.status == 401
      raise NotAllowed.new(error_message(response)) if response.status == 403
      raise NotFound.new(error_message(response)) if response.status == 404
      raise ValidationFailed.new(error_message(response)) if response.status == 422
      raise ApiFailure.new(error_message(response)) # fallback
    end

    def error_message(response)
      data = JSON.parse(response.body)
      # field validation error response contain a message and an
      # array of errors, so include all messages
      if data['errors']
        errors = data['errors'].map {|e| e['message'] }
        "#{data['message']}, #{errors.join(',')}"
      elsif data['message']
        data['message']
      else
        response.body
      end
    rescue
      # problem parsing or traversing json, return original api error
      response.body
    end

    def headers
      {
        'Authorization': "Bearer #{@api_key}",
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      }
    end
  end
end
