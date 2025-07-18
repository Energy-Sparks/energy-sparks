# frozen_string_literal: true

require 'rails_helper'

describe DataFeeds::PerseApi do
  around do |example|
    ClimateControl.modify PERSE_API_URL: 'http://example.com', PERSE_API_KEY: 'key' do
      example.run
    end
  end

  describe '#meter_history_realtime_data' do
    it 'calls the relevant API' do
      stub = stub_request(:get, 'http://example.com/meterhistory/v2/realtime-data?MPAN=mpan&fromDate=2024-01-01')
      api = described_class.new
      api.meter_history_realtime_data('mpan', Date.new(2024, 1, 1))
      expect(stub).to have_been_requested
      request = WebMock::RequestRegistry.instance.requested_signatures.hash.keys[0]
      expect(request.headers['api_key']).to eq('key')
      expect(request.headers['content-type']).to eq('application/json')
    end
  end
end
