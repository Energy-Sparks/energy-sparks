# frozen_string_literal: true

module DataFeeds
  module SolarEdge
    class Api
      class TokenExchangeFailure < StandardError; end

      CONNECT_BASE = 'https://connect.solaredge.com'
      API_BASE = 'https://monitoringapi.solaredge.com/v2'
      POST_HEADERS = { 'Content-Type' => 'application/json' }.freeze

      def initialize(client_id: ENV.fetch('SOLAR_EDGE_CLIENT_ID', nil),
                     client_secret: ENV.fetch('SOLAR_EDGE_CLIENT_SECRET', nil),
                     stubs: nil)
        @client_id = client_id
        @client_secret = client_secret
        @connection = FaradayHelper.connection(url: API_BASE, retry_options: { retry_statuses: [429] }) do |f|
          f.adapter(:test, stubs) if stubs
          f.response :json
        end
      end

      # Create user facing URL to start OAuth workflow
      def self.authorize_url(school_id, client_id: ENV.fetch('SOLAR_EDGE_CLIENT_ID', nil))
        "#{CONNECT_BASE}/authorize?client_id=#{client_id}&external_id=#{school_id}"
      end

      # Exchange code from callback for access and refresh tokens
      def retrieve_access_token(code)
        body = with_secrets({
                              'grant_type' => 'authorization_code',
                              'code' => code
                            })
        response = @connection.post('/v2/oauth2/token', body, POST_HEADERS)
        response.body
      end

      # Use refresh token to get new access and refresh tokens
      def refresh_access_token(refresh_token)
        body = with_secrets({
                              'grant_type' => 'refresh_token',
                              'refresh_token' => refresh_token
                            })
        response = @connection.post('/v2/oauth2/token', body, POST_HEADERS)
        response.body
      end

      private

      def with_secrets(params)
        params.merge({
                       'client_id' => @client_id,
                       'client_secret' => @client_secret
                     })
      end
    end
  end
end
