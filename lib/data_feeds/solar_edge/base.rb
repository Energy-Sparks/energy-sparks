# frozen_string_literal: true

module DataFeeds
  module SolarEdge
    class Base
      API_BASE = 'https://monitoringapi.solaredge.com/v2'
      POST_HEADERS = { 'Content-Type' => 'application/json' }.freeze
    end
  end
end
