# frozen_string_literal: true

module DataFeeds
  class GeoApi
    class ApiFailure < StandardError; end
    class NotFound < StandardError; end
    class NotAllowed < StandardError; end
    class NotAuthorised < StandardError; end

    BASE_URL = 'https://api.geotogether.com/api'

    # instantiate with username and password, then call login to set (and return) token
    # - same instance can then be used for data calls
    # OR
    # instantiate with token from previous login and use without login call
    def initialize(username: nil, password: nil, token: nil)
      @username = username
      @password = password
      @token = token
    end

    def login
      url = '/userapi/account/login'
      payload = { emailAddress: @username, password: @password }
      data = post_data(url, payload)
      @token = data['token']
    end

    def trigger_fast_update(system_id)
      url = "/supportapi/system/trigger-fastupdate/#{system_id}"
      get_data(url)
    end

    def live_data(system_id)
      url = "/supportapi/system/smets2-live-data/#{system_id}"
      get_data(url)
    end

    def periodic_data(system_id)
      url = "/supportapi/system/smets2-periodic-data/#{system_id}"
      get_data(url)
    end

    def daily_data(system_id)
      url = "/supportapi/system/smets2-daily-data/#{system_id}"
      get_data(url)
    end

    def historic_day(system_id, start_date, end_date)
      url = "/supportapi/system/smets2-historic-day/#{system_id}?from=#{utc_date(start_date)}&to=#{utc_date(end_date)}"
      get_data(url)
    end

    def historic_week(system_id, start_date, end_date)
      url = "/supportapi/system/smets2-historic-week/#{system_id}?from=#{utc_date(start_date)}&to=#{utc_date(end_date)}"
      get_data(url)
    end

    def historic_month(system_id, from_month, from_year, to_month, to_year)
      url = "/supportapi/system/smets2-historic-month/#{system_id}?fromMonth=#{from_month}&fromYear=#{from_year}&toMonth=#{to_month}&toYear=#{to_year}"
      get_data(url)
    end

    def epochs(system_id, start_date, end_date)
      url = "/supportapi/system/epochs/#{system_id}?from=#{utc_date(start_date)}&to=#{utc_date(end_date)}"
      get_data(url)
    end

    def summaries(system_id, start_date, end_date)
      url = "/supportapi/system/summaries/#{system_id}?from=#{utc_date(start_date)}&to=#{utc_date(end_date)}"
      get_data(url)
    end

    private

    def headers
      hdr = {
        Accept: 'application/json',
        'Content-Type': 'application/json'
      }
      hdr[:Authorization] = "Bearer #{@token}" if @token
      hdr
    end

    def get_data(path)
      check_token
      response = Faraday.get(BASE_URL + path, nil, headers)
      handle_response(response)
    end

    def post_data(path, payload)
      check_credentials
      response = Faraday.post(BASE_URL + path, payload.to_json, headers)
      handle_response(response)
    end

    def handle_response(response)
      raise NotAuthorised, error_message(response) if response.status == 401
      raise NotAllowed, error_message(response) if response.status == 403
      raise NotFound, error_message(response) if response.status == 404
      raise ApiFailure, error_message(response) unless response.success?

      begin
        JSON.parse(response.body)
      rescue StandardError
        # problem parsing or traversing json, return original body
        response.body
      end
    end

    def error_message(response)
      data = JSON.parse(response.body)
      if data['reason']
        data['reason']
        elseif data['error']
        data['error']
      else
        response.body
      end
    rescue StandardError
      # problem parsing or traversing json, return original api error
      response.body
    end

    def check_credentials
      raise ApiFailure, 'Username and password, or token must be set' if @username.blank? || @password.blank?
    end

    def check_token
      raise ApiFailure, 'token must be set' if @token.blank?
    end

    def utc_date(date)
      date.strftime('%Y-%m-%d')
    end
  end
end
