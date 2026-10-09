# frozen_string_literal: true

RSpec.shared_context 'with SolarEdge credentials' do
  around do |example|
    ClimateControl.modify SOLAR_EDGE_CLIENT_ID: 'solar_edge_client_id', SOLAR_EDGE_CLIENT_SECRET: 'solar_edge_secret' do
      example.run
    end
  end
end
