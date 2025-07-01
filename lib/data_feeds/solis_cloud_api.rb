# frozen_string_literal: true

require 'base64'

module DataFeeds
  class SolisCloudApi
    extend Limiter::Mixin

    BASE_URL = 'https://www.soliscloud.com:13333'

    def initialize(api_id, api_secret)
      @api_id = api_id
      @api_secret = api_secret
    end

    def user_station_list
      get_data('/v1/api/userStationList', {})
    end

    def inverter_detail_list
      get_data('/v1/api/inverterDetailList', {})
    end

    limit_method :station_day, rate: 1, interval: 2 unless Rails.env.test?
    def station_day(id, day)
      get_data('/v1/api/stationDay', { id: id, money: 'GBP', time: day.iso8601, timeZone: 0 })
    end

    limit_method :inverter_day, rate: 2, interval: 1, balanced: true unless Rails.env.test? # API docs say 2 times/sec
    def inverter_day(serial, day)
      get_data('/v1/api/inverterDay', { sn: serial, money: 'GBP', time: day.iso8601, timeZone: 0 })
    end

    private

    def connection
      Faraday.new(BASE_URL) do |f|
        f.response :json
        f.response :raise_error
        f.response :logger if Rails.env.development?
        f.request(:retry, { retry_statuses: [429], interval: 2.0, backoff_factor: 2 })
      end
    end

    def content_md5(body)
      Base64.encode64(Digest::MD5.digest(body)).chomp
    end

    def authorization(path, headers)
      signature = "POST\n#{headers['Content-MD5']}\n#{headers['Content-Type']}\n#{headers['Date']}\n#{path}"
      hmac = OpenSSL::HMAC.digest('sha1', @api_secret, signature.encode('utf-8'))
      "API #{@api_id}:#{Base64.encode64(hmac).chomp}"
    end

    def get_data(path, body)
      body = body.to_json
      headers = {
        'Content-MD5' => content_md5(body),
        'Date' => DateTime.now.httpdate,
        'Content-Type' => 'application/json'
      }
      headers['Authorization'] = authorization(path, headers)
      response = connection.post(path, body, headers)
      response.body
    end
  end
end
