# frozen_string_literal: true

require 'rails_helper'
require 'faraday/adapter/test'

describe DataFeeds::SolarEdgeApi do
  subject(:client) { described_class.new(api_key, connection) }

  let(:stubs)       { Faraday::Adapter::Test::Stubs.new }
  let(:connection)  { Faraday.new { |b| b.adapter(:test, stubs) } }
  let(:api_key)     { 'fake' }
  let(:site_id) { 123 }

  after do
    Faraday.default_connection = nil
  end

  describe '#site_start_end_dates' do
    before do
      stubs.get("/site/#{site_id}/dataPeriod?api_key=#{api_key}") do |_env|
        [200, {}, body.to_json]
      end
    end

    context 'with valid dates' do
      let(:body) do
        {
          dataPeriod: {
            startDate: '2025-01-01',
            endDate: '2026-05-11'
          }
        }
      end

      it 'returns data' do
        expect(client.site_start_end_dates(site_id)).to eql [Date.new(2025, 1, 1), Date.new(2026, 5, 11)]
        stubs.verify_stubbed_calls
      end
    end

    context 'when site is still in Pending status' do
      let(:body) do
        {
          dataPeriod: {
            startDate: nil,
            endDate: '2026-05-11'
          }
        }
      end

      it 'returns data' do
        expect(client.site_start_end_dates(site_id)).to eql [nil, Date.new(2026, 5, 11)]
        stubs.verify_stubbed_calls
      end
    end
  end

  # minimal test of HTTP response handling behaviour
  describe '#site_details' do
    before do
      stubs.get("/sites/list?api_key=#{api_key}") do |_env|
        [status, {}, body.to_json]
      end
    end

    context 'with success' do
      let(:status) { 200 }
      let(:body) do
        {
          'sites' => {
            'count' => 1,
            'site' => {
              'id' => '1234'
            }
          }
        }
      end

      it 'returns data' do
        expect(client.site_details).to eql body
        stubs.verify_stubbed_calls
      end
    end

    context 'with 403 error' do
      let(:status) { 403 }

      let(:body) do
        {
          String: 'Invalid token'
        }
      end

      it 'throws exception' do
        expect do
          client.site_details
        end.to raise_error(DataFeeds::SolarEdgeApi::NotAllowed)
        stubs.verify_stubbed_calls
      end
    end

    context 'with other error' do
      let(:status)      { 500 }

      let(:body) do
        {
          String: 'Server Error'
        }
      end

      it 'throws exception' do
        expect do
          client.site_details
        end.to raise_error(DataFeeds::SolarEdgeApi::ApiFailure)
        stubs.verify_stubbed_calls
      end
    end
  end

  describe '#smart_meter_data' do
    let(:query) do
      {
        'timeUnit' => 'QUARTER_OF_AN_HOUR',
        'startTime' => '2026-01-21 00:00:00',
        'endTime' => '2026-01-22 00:00:00',
        'api_key' => api_key
      }
    end
    let(:expected_data) do
      {
        electricity: {
          missing_readings: [],
          readings: {
            Date.new(2026, 1,
                     21) => Array.new(25, 2.0) + [1.0] + Array.new(22, 2.0)
          }
        },
        exported_solar_pv: {
          missing_readings: [],
          readings: {
            Date.new(2026, 1, 21) => Array.new(48, 0.0)
          }
        },
        solar_pv: {
          missing_readings: [],
          readings: {
            Date.new(2026, 1,
                     21) => Array.new(18,
                                      0.0) + Array.new(7, 1.0) + [0.5] + Array.new(6, 1.0) + Array.new(16, 0.0)
          }
        }
      }
    end

    before do
      stubs.get("/site/#{site_id}/dataPeriod?api_key=#{api_key}") do |_env|
        [
          200,
          {},
          {
            dataPeriod: {
              startDate: '2026-01-21',
              endDate: '2026-01-21'
            }
          }.to_json
        ]
      end
    end

    context 'when successfully querying for a date range' do
      subject(:response) do
        client.smart_meter_data(site_id, Date.new(2026, 1, 21), Date.new(2026, 1, 21))
      end

      it 'requests the expected dates' do
        stubs.get("/site/#{site_id}/energyDetails") do |env|
          expect(env.params).to include(query)
          [200, {}, File.read('spec/fixtures/solar_edge/energy_details.json')]
        end
        expect(response).to eq(expected_data)
        stubs.verify_stubbed_calls
      end
    end

    context 'when successfully querying with open dates' do
      subject(:response) do
        client.smart_meter_data(site_id, nil, nil)
      end

      it 'requests data using the dataPeriod' do
        stubs.get("/site/#{site_id}/energyDetails") do |env|
          expect(env.params).to include(query)
          [200, {}, File.read('spec/fixtures/solar_edge/energy_details.json')]
        end

        expect(response).to eq(expected_data)
        stubs.verify_stubbed_calls
      end
    end
  end
end
