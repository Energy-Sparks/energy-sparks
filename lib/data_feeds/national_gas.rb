# frozen_string_literal: true

module DataFeeds
  class NationalGas
    def initialize
      @connection = Faraday.new('https://data.nationalgas.com') do |f|
        f.response :raise_error
        f.response :logger if Rails.env.development?
      end
    end

    def find_gas_data_download(date_from, date_to, publication_id)
      params = { dateFrom: date_from.iso8601,
                 dateTo: date_to.iso8601,
                 dateType: :GASDAY,
                 ids: publication_id,
                 applicableFor: :Y,
                 latestFlag: :Y,
                 type: :CSV }
      @connection.get('/api/find-gas-data-download', params).body
    end
  end
end
