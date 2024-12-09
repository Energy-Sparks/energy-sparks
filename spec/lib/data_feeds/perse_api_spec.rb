# frozen_string_literal: true

require 'rails_helper'

describe DataFeeds::PerseApi do
  describe '#meter_history_realtime_data' do
    it 'calls the relevant API' do
      stub = stub_request(:get, 'http://example.com/meterhistory/v2/realtime-data?MPAN=mpan&fromDate=2024-01-01')
      ClimateControl.modify PERSE_API_URL: 'http://example.com', PERSE_API_KEY: 'key' do
        described_class.meter_history_realtime_data('mpan', Date.new(2024, 1, 1))
      end
      expect(stub).to have_been_requested
      request = WebMock::RequestRegistry.instance.requested_signatures.hash.keys[0]
      expect(request.headers['api_key']).to eq('key')
      expect(request.headers['content-type']).to eq('application/json')
    end
  end
end
