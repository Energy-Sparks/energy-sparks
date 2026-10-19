# frozen_string_literal: true

require 'rails_helper'

describe DataFeeds::SolarEdge::SiteApi do
  subject(:api) do
    described_class.new(site_id: site.site_id,
                        access_token: site.access_token,
                        stubs:)
  end

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

  # Stubs a fixed day with readings at specific time periods to check mapping to half-hourly periods,
  # addition, etc.
  def stub_request_for_days_readings(path:)
    response = {
      'resolution' => 'QUARTER_HOUR',
      'values' => [
        { 'timestamp' => '2026-08-01T00:00:00+01:00', 'value' => 0.0 },
        { 'timestamp' => '2026-08-01T00:15:00+01:00', 'value' => 0.0 },
        { 'timestamp' => '2026-08-01T08:00:00+01:00', 'value' => 20.0 },
        { 'timestamp' => '2026-08-01T08:15:00+01:00', 'value' => 20.0 },
        { 'timestamp' => '2026-08-01T08:30:00+01:00', 'value' => nil },
        { 'timestamp' => '2026-08-01T08:45:00+01:00', 'value' => 50.0 },
        { 'timestamp' => '2026-08-01T09:00:00+01:00', 'value' => nil },
        { 'timestamp' => '2026-08-01T09:15:00+01:00', 'value' => nil }
      ]
    }
    stub_request(path:, params: {
                   'resolution' => 'QUARTER_HOUR',
                   'unit' => 'KWH',
                   'from' => '2026-08-01T00:00:00+01:00',
                   'to' => '2026-08-01T12:00:00+01:00'
                 }, response:)

    stub_request(path: path, params: {
                   'resolution' => 'QUARTER_HOUR',
                   'unit' => 'KWH',
                   'from' => '2026-08-01T12:00:00+01:00',
                   'to' => '2026-08-02T00:00:00+01:00'
                 }, response: { 'values' => [] })
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

  describe '#energy' do
    let(:response) do
      {
        'period' => { 'from' => '2024-01-01T00:00:00+00:00', 'to' => '2024-01-01T12:00:00+00:00' },
        'unit' => 'KWH',
        'resolution' => 'TOTAL',
        'values' => [{ 'timestamp' => '2026-10-08T00:00:00+01:00', 'value' => 314.27 }]
      }
    end

    before do
      stub_request(path: '/energy', params: {
                     'resolution' => 'TOTAL',
                     'unit' => 'KWH',
                     'from' => '2024-01-01T00:00:00+00:00',
                     'to' => '2024-01-01T12:00:00+00:00'
                   }, response:)
    end

    it 'returns the parsed response' do
      expect(api.energy(
               resolution: 'TOTAL',
               from: DateTime.parse('2024-01-01T00:00:00'),
               to: DateTime.parse('2024-01-01T12:00:00')
             )).to eq(response)
    end
  end

  describe '#date_range' do
    let(:response) do
      {
        'period' => { 'from' => '2024-01-01T00:00:00+01:00', 'to' => '2026-01-02T13:43:01.713+01:00' },
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
                                     to: DateTime.parse('2026-01-02T13:43:01.713+01:00')
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

  describe '#production' do
    before do
      stub_request_for_days_readings(path: '/energy')
    end

    it 'aggregates the production data to correct half-hourly indexes' do
      day = Date.new(2026, 8, 1)
      data = api.production(start_date: day, end_date: day)
      expect(data[day][0]).to eq(0.0)
      expect(data[day][16]).to eq(40.0)
      expect(data[day][17]).to eq(50.0)
      expect(data[day][18..47]).to eq(Array.new(30, nil))
    end
  end

  describe '#import_energy' do
    let(:serial_number) { 5555 }

    before do
      stub_request_for_days_readings(path: "/meters/#{serial_number}/import-energy")
    end

    it 'aggregates the import data to correct half-hourly indexes' do
      day = Date.new(2026, 8, 1)
      data = api.import_energy(serial_number:, start_date: day, end_date: day)
      expect(data[day][0]).to eq(0.0)
      expect(data[day][16]).to eq(40.0)
      expect(data[day][17]).to eq(50.0)
      expect(data[day][18..47]).to eq(Array.new(30, nil))
    end
  end

  describe '#export_energy' do
    let(:serial_number) { 5555 }

    before do
      stub_request_for_days_readings(path: "/meters/#{serial_number}/export-energy")
    end

    it 'aggregates the import data to correct half-hourly indexes' do
      day = Date.new(2026, 8, 1)
      data = api.export_energy(serial_number:, start_date: day, end_date: day)
      expect(data[day][0]).to eq(0.0)
      expect(data[day][16]).to eq(40.0)
      expect(data[day][17]).to eq(50.0)
      expect(data[day][18..47]).to eq(Array.new(30, nil))
    end
  end
end
