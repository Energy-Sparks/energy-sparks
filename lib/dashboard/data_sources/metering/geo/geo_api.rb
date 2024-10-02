module MeterReadingsFeeds
  class GeoApi
    include Logging

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

    def trigger_fast_update(systemId)
      url = '/supportapi/system/trigger-fastupdate/' + systemId
      get_data(url)
    end

    def live_data(systemId)
      url = '/supportapi/system/smets2-live-data/' + systemId
      get_data(url)
    end

    def periodic_data(systemId)
      url = '/supportapi/system/smets2-periodic-data/' + systemId
      get_data(url)
    end

    def daily_data(systemId)
      url = '/supportapi/system/smets2-daily-data/' + systemId
      get_data(url)
    end

    def historic_day(systemId, start_date, end_date)
      url = "/supportapi/system/smets2-historic-day/#{systemId}?from=#{utc_date(start_date)}&to=#{utc_date(end_date)}"
      get_data(url)
    end

    def historic_week(systemId, start_date, end_date)
      url = "/supportapi/system/smets2-historic-week/#{systemId}?from=#{utc_date(start_date)}&to=#{utc_date(end_date)}"
      get_data(url)
    end

    def historic_month(systemId, from_month, from_year, to_month, to_year)
      url = "/supportapi/system/smets2-historic-month/#{systemId}?fromMonth=#{from_month}&fromYear=#{from_year}&toMonth=#{to_month}&toYear=#{to_year}"
      get_data(url)
    end

    def epochs(systemId, start_date, end_date)
      url = "/supportapi/system/epochs/#{systemId}?from=#{utc_date(start_date)}&to=#{utc_date(end_date)}"
      get_data(url)
    end

    def summaries(systemId, start_date, end_date)
      url = "/supportapi/system/summaries/#{systemId}?from=#{utc_date(start_date)}&to=#{utc_date(end_date)}"
      get_data(url)
    end

    private

    def headers
      hdr = {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      }
      hdr.merge!({'Authorization': "Bearer #{@token}"}) if @token
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
      raise NotAuthorised.new(error_message(response)) if response.status == 401
      raise NotAllowed.new(error_message(response)) if response.status == 403
      raise NotFound.new(error_message(response)) if response.status == 404
      raise ApiFailure.new(error_message(response)) unless response.success?
      begin
        JSON.parse(response.body)
      rescue => e
        #problem parsing or traversing json, return original body
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
    rescue => e
      #problem parsing or traversing json, return original api error
      response.body
    end

    def check_credentials
      raise ApiFailure.new('Username and password, or token must be set') if @username.blank? || @password.blank?
    end

    def check_token
      raise ApiFailure.new('token must be set') if @token.blank?
    end

    def utc_date(date)
      date.strftime('%Y-%m-%d')
    end
  end
end
