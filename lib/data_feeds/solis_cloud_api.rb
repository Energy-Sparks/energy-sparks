# frozen_string_literal: true

require 'base64'

module DataFeeds
  class SolisCloudApi
    class ApiFailure < StandardError; end
    class NotFound < StandardError; end
    class NotAllowed < StandardError; end
    class NotAuthorised < StandardError; end

    BASE_URL = 'https://www.soliscloud.com:13333'

    def initialize(api_id = ENV['SOLIS_API_ID'], api_secret = ENV['SOLIS_API_SECRET'])
      @api_id = api_id
      @api_secret = api_secret
    end

    def user_station_list
      get_data('/v1/api/userStationList', { 'pageNo': 1, 'pageSize': 10 })
    end

    def station_day(id, day)
      get_data('/v1/api/stationDay', { 'id': id, 'money': 'GBP', 'time': day.iso8601, 'timeZone': 44 })
    end

    def inverter_day(serial_num, day)
      get_data('/v1/api/inverterDay', { 'sn': serial_num, 'money': 'GBP', 'time': day.iso8601, 'timeZone': 44 })
    end

    private

    def get_data(path, data)
      content_type = 'application/json'
      date = DateTime.now.httpdate

      body = data.to_json
      md5 = Digest::MD5.digest(body)
      content_md5 = Base64.encode64(md5).chomp

      signature = "POST\n#{content_md5}\n#{content_type}\n#{date}\n#{path}"

      hmac = OpenSSL::HMAC.digest('sha1', @api_secret, signature.encode('utf-8'))
      authorization = 'API ' + @api_id + ':' + Base64.encode64(hmac).chomp

      headers = {
          'Content-MD5': content_md5,
          'Date': date,
          'Content-Type': content_type,
          'Authorization': authorization
      }

      response = Faraday.post(BASE_URL + path, body, headers)
      handle_response(response)
    end

    def handle_response(response)
      raise NotAuthorised, response.body if response.status == 401
      raise NotAllowed, response.body if response.status == 403
      raise NotFound, response.body if response.status == 404
      raise ApiFailure, response.body unless response.success?

      begin
        JSON.parse(response.body)
      rescue StandardError => e
        raise ApiFailure, e.message
      end
    end
  end
end
