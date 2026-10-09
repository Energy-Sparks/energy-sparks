# frozen_string_literal: true

require 'rails_helper'

describe DataFeeds::SolarEdge::SiteApi do
  subject(:api) do
    described_class.new(site_id: site.site_id,
                        access_token: site.access_token,
                        stubs:)
  end

  let(:status) { 200 }
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }

  let(:site) { create(:solar_edge_installation) }

  after do
    Faraday.default_connection = nil
    stubs.verify_stubbed_calls
  end

  def stub_request(path:, code: 200, response: {}, params: nil)
    stubs.get("#{DataFeeds::SolarEdge::Base::API_BASE}/sites/#{site.site_id}#{path}") do |env|
      expect(env.request_headers['Authorization']).to eq("Bearer #{site.access_token}")
      expect(env.params).to eq(params) if params
      [code, { 'Content-Type': 'application/json' }, response.to_json]
    end
  end

  describe '#details' do
    let(:response) do
      {
        'siteId' => site.site_id,
        'activationStatus' => 'ACTIVE'
      }
    end

    it 'returns the parsed response' do
      stub_request(path: nil, response:)
      expect(api.details).to eq(response)
    end
  end

  describe '#status' do
    context 'with an ACTIVE site' do
      it 'returns true' do
        stub_request(path: nil, response: { 'activationStatus' => 'ACTIVE' })
        expect(api.active?).to be(true)
      end
    end

    context 'with a PENDING site' do
      it 'returns false' do
        stub_request(path: nil, response: { 'activationStatus' => 'PENDING' })
        expect(api.active?).to be(false)
      end
    end
  end

  describe '#energy' do
    let(:response) do
      {
        'period' => { 'from' => '2024-01-01T00:00:00+01:00', 'to' => '2024-01-02T13:43:01.713+01:00' },
        'unit' => 'KWH',
        'resolution' => 'TOTAL',
        'values' => [{ 'timestamp' => '2026-10-08T00:00:00+01:00', 'value' => 314.27 }]
      }
    end

    before do
      stub_request(path: '/energy', params: {
                     'resolution' => 'TOTAL',
                     'unit' => 'KWH',
                     'from' => DateTime.new(2024, 1, 1).iso8601,
                     'to' => DateTime.new(2024, 1, 2).iso8601
                   }, response:)
    end

    it 'returns the parsed response' do
      expect(api.energy(
               resolution: 'TOTAL',
               from: DateTime.new(2024, 1, 1),
               to: DateTime.new(2024, 1, 2)
             )).to eq(response)
    end
  end

  describe '#date_range' do
    let(:response) do
      {
        'period' => { 'from' => '2024-01-01T00:00:00+01:00', 'to' => '2024-01-02T13:43:01.713+01:00' },
        'unit' => 'KWH',
        'resolution' => 'TOTAL',
        'values' => [{ 'timestamp' => '2026-10-08T00:00:00+01:00', 'value' => 314.27 }]
      }
    end

    before do
      stub_request(path: '/energy', params: {
                     'resolution' => 'TOTAL',
                     'from' => DateTime.new(2000).iso8601,
                     'unit' => 'KWH'
                   }, response:)
    end

    it 'returns the parsed dates' do
      expect(api.date_range).to eq({
                                     from: DateTime.parse('2024-01-01T00:00:00+01:00'),
                                     to: DateTime.parse('2024-01-02T13:43:01.713+01:00')
                                   })
    end
  end

  describe '#inventory' do
    let(:response) do
      [
        {
          'type' => 'METER',
          'serialNumber' => nil,
          'connectedToName' => 'Inverter 1',
          'active' => true,
          'name' => 'Consumption Meter',
          'meterType' => 'Consumption'
        },
        {
          'type' => 'METER',
          'serialNumber' => '5118719',
          'connectedTo' => '7B0EB83A-7B',
          'active' => true,
          'name' => 'Export Meter',
          'meterType' => 'FeedIn'
        },
        {
          'type' => 'METER',
          'serialNumber' => '5118719',
          'connectedTo' => '7B0EB83A-7B',
          'active' => true,
          'name' => 'Import Meter',
          'meterType' => 'Purchased'
        },
        {
          'type' => 'METER',
          'serialNumber' => nil,
          'connectedTo' => '7B0EB83A-7B',
          'active' => true,
          'name' => 'Self Consumption',
          'meterType' => 'SelfConsumption'
        }
      ]
    end

    it 'returns the parsed response' do
      stub_request(path: '/devices', params: { 'types' => 'METER' }, response:)
      expect(api.inventory).to eq(response)
    end
  end

  describe '#meters_telemetry' do
    let(:response) do
      {
        'period' => { 'from' => '2024-01-01T00:00:00+01:00', 'to' => '2024-01-02T13:43:01.713+01:00' },
        'unit' => 'KWH',
        'resolution' => 'QUARTER_HOUR',
        'meters' => {
          '5118719' => {
            'importEnergy' => {
              'unit' => 'WH',
              'values' => [{ 'timestamp' => '2024-01-01T00:00:00+01:00', 'value' => 314.27 }]
            },
            'importPower' => {
              'unit' => 'WH',
              'values' => []
            },
            'exportEnergy' => {
              'unit' => 'WH',
              'values' => [{ 'timestamp' => '2024-01-01T00:00:00+01:00', 'value' => 314.27 }]
            },
            'exportPower' => {
              'unit' => 'WH',
              'values' => []
            }
          }
        }
      }
    end

    before do
      stub_request(path: '/meters/telemetry', params: {
                     'resolution' => 'QUARTER_HOUR',
                     'from' => DateTime.new(2024, 1, 1).iso8601,
                     'to' => DateTime.new(2024, 1, 2).iso8601
                   }, response:)
    end

    it 'returns the parsed response' do
      expect(api.meters_telemetry(
               from: DateTime.new(2024, 1, 1),
               to: DateTime.new(2024, 1, 2)
             )).to eq(response)
    end
  end
end
