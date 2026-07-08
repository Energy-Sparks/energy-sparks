# frozen_string_literal: true

module DataFeeds
  class PvLiveApi
    class ApiFailure < StandardError; end

    BASE_URL = 'https://api.pvlive.uk/pvlive/api/v4'

    def initialize
      @connection = FaradayHelper.connection(url: BASE_URL,
                                             request: { params_encoder: Faraday::FlatParamsEncoder }) do |f|
        f.response(:json, parser_options: { symbolize_names: true })
      end
    end

    def gsp_list = get_data('gsp_list')

    def gsp(gsp_id, start_date = nil, end_date = nil, extra_fields: ['installedcapacity_mwp'])
      get_data("gsp/#{gsp_id}", { extra_field: extra_fields,
                                  start: ("#{format_date(start_date)}T00:00:00Z" if start_date),
                                  end: ("#{format_date(end_date)}T23:59:59Z" if end_date) }.compact)
    end

    private

    def get_data(path, params = {}, headers = {})
      response = @connection.get(path, params, headers)
      handle_response(response)
    end

    def handle_response(response)
      raise ApiFailure, response.body[:error_description] if response.body[:error_description]

      response.body
    end

    def format_date(date) = date.strftime('%Y-%m-%d')
  end
end
