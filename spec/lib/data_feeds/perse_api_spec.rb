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
      described_class.meter_history_realtime_data('mpan', Date.new(2024, 1, 1))
      expect(stub).to have_been_requested
      request = WebMock::RequestRegistry.instance.requested_signatures.hash.keys[0]
      expect(request.headers['api_key']).to eq('key')
      expect(request.headers['content-type']).to eq('application/json')
    end
  end

  describe '#meter_readings' do
    it 'parses sandbox data' do
      stub_request(:get, 'http://example.com/meterhistory/v2/realtime-data?MPAN=mpan&fromDate=2024-01-01')
        .to_return(body: File.read('spec/fixtures/perse/meter_history_v2_realtime-data.json'),
                   headers: { 'content-type': 'application/json' })
      readings = described_class.meter_readings('mpan', Date.new(2024, 1, 1))
      expect(readings.first).to eq([Date.new(2024, 12, 1), [17.4, 17.7, 17.5, 17.9, 17.9, 17.0, 17.1, 17.9, 18.0, 16.6,
                                                            17.8, 20.9, 19.3, 18.9, 17.4, 18.6, 18.1, 18.1, 17.4, 18.9,
                                                            18.6, 17.7, 17.9, 18.9, 19.1, 18.9, 17.9, 19.5, 18.6, 18.0,
                                                            17.0, 19.3, 19.0, 17.1, 17.8, 18.5, 17.8, 18.4, 17.9, 18.0,
                                                            17.2, 16.7, 15.8, 17.5, 17.1, 15.0, 15.4, 16.1]])
    end
  end
end
