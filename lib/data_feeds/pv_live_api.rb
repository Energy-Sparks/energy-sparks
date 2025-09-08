# frozen_string_literal: true

module DataFeeds
  class PvLiveApi
    class ApiFailure < StandardError; end

    BASE_URL = 'https://api.pvlive.uk/pvlive/api/v4'

    def gsp_list
      get_data('/gsp_list')
    end

    def gsp(gsp_id, start_date = nil, end_date = nil, extra_fields = ['installedcapacity_mwp'])
      params = {
        data_format: 'json',
        extra_fields: extra_fields.join(',')
      }
      params[:start] = date_to_url_format(start_date, true) unless start_date.nil?
      params[:end] = date_to_url_format(end_date, false) unless end_date.nil?

      get_data("/gsp/#{gsp_id}", params)
    end

    private

    def get_data(path, params = {}, headers = {})
      response = Faraday.get(BASE_URL + path, params, headers)
      handle_response(response)
    end

    def handle_response(response)
      raise ApiFailure, response.body unless response.success?

      begin
        body = JSON.parse(response.body, symbolize_names: true)
      rescue StandardError
        raise ApiFailure, response.body
      end
      raise ApiFailure, body[:error_description] if body[:error_description]

      body
    end

    def date_to_url_format(date, start)
      d_url = date.strftime('%Y-%m-%d')
      d_url += start ? 'T00:00:00Z' : 'T23:59:59Z'
      d_url
    end
  end
end
