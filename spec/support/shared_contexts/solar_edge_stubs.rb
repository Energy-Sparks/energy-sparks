# frozen_string_literal: true

RSpec.shared_context 'with SolarEdge credentials' do
  before { stub_env(SOLAR_EDGE_CLIENT_ID: 'solar_edge_client_id', SOLAR_EDGE_CLIENT_SECRET: 'solar_edge_secret') }
end

RSpec.shared_context 'with a successful SolarEdge token request' do
  before do
    response = {
      access_token: '2YotnFZFEjr1zCsicMWpAA',
      token_type: 'Bearer',
      expires_in: 7200,
      refresh_token: 'tGzv3JOkF0XG5Qx2TlKWIA'
    }
    stub_request(:post, 'https://monitoringapi.solaredge.com/v2/oauth2/token')
      .to_return(
        status: 200,
        body: response.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end
end

RSpec.shared_context 'with a failed SolarEdge token request' do
  before do
    response = {
      error: 'Error',
      error_description: 'Invalid code'
    }
    stub_request(:post, 'https://monitoringapi.solaredge.com/v2/oauth2/token')
      .to_return(
        status: 400,
        body: response.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end
end

RSpec.shared_context 'with a stubbed SolarEdge site details request' do
  let(:status) { 200 }
  let(:activation_status) { 'ACTIVE' }

  before do
    stub_request(:get, "#{DataFeeds::SolarEdge::Api::API_BASE}/sites/#{site_id}")
      .to_return(
        status:,
        headers: {
          'Content-Type' => 'application/json'
        },
        body: {
          'siteId' => site_id,
          'activationStatus' => activation_status
        }.to_json
      )
  end
end

RSpec.shared_context 'with a stubbed SolarEdge date request' do
  let(:from) { '2024-01-01T00:00:00+01:00' }
  let(:to) { '2026-01-02T13:43:01+01:00' }

  before do
    stub_request(:get, "#{DataFeeds::SolarEdge::Api::API_BASE}/sites/#{site_id}/" \
                       'energy?from=2000-01-01T00:00:00%2B00:00&resolution=TOTAL&unit=KWH')
      .to_return(
        status: 200,
        headers: {
          'Content-Type' => 'application/json'
        },
        body: {
          'period' => { 'from' => from, 'to' => to }
        }.to_json
      )
  end
end

RSpec.shared_context 'with a stubbed SolarEdge inventory request' do
  before do
    stub_request(:get, "#{DataFeeds::SolarEdge::Api::API_BASE}/sites/#{site_id}/" \
                       'devices?types=METER')
      .to_return(
        status: 200,
        headers: {
          'Content-Type' => 'application/json'
        },
        body: [
          { 'type' => 'METER', 'active' => true, 'meterType' => 'FeedIn', 'name' => 'Export Meter',
            'serialNumber' => '12345' },
          { 'type' => 'METER', 'active' => true, 'meterType' => 'Purchased', 'name' => 'Import Meter',
            'serialNumber' => '12345' },
          { 'type' => 'METER', 'active' => true, 'meterType' => 'SelfConsumption', 'name' => 'Self Consumption' },
          { 'type' => 'METER', 'active' => true, 'meterType' => 'Consumption', 'name' => 'Consumption Meter' }
        ].to_json
      )
  end
end
