# frozen_string_literal: true

require 'rails_helper'

describe Amr::PerseUpsert do
  describe '#perform' do
    subject(:upserter) { described_class.new }

    around do |example|
      travel_to(Date.new(2024, 12, 10))
      create(:amr_data_feed_config, identifier: 'perse-half-hourly-api')
      ClimateControl.modify PERSE_API_URL: 'http://example.com', PERSE_API_KEY: 'key' do
        example.run
      end
    end

    it 'imports readings' do
      meter = create(:gas_meter)
      stub_request(:get, "http://example.com/meterhistory/v2/realtime-data?MPAN=#{meter.mpan_mprn}&fromDate=2023-10-10")
        .to_return(body: File.read('spec/fixtures/perse/meter_history_v2_realtime-data.json'),
                   headers: { 'content-type': 'application/json' })
      upserter.perform(meter)
      expect(AmrDataFeedReading.where(meter: meter).count).to eq(331)
      expect(AmrDataFeedReading.where(meter: meter, reading_date: '2024-12-01').pluck(:readings)).to eq(
        [
          [
            17.4, 17.7, 17.5, 17.9, 17.9, 17.0, 17.1, 17.9, 18.0, 16.6,
            17.8, 20.9, 19.3, 18.9, 17.4, 18.6, 18.1, 18.1, 17.4, 18.9,
            18.6, 17.7, 17.9, 18.9, 19.1, 18.9, 17.9, 19.5, 18.6, 18.0,
            17.0, 19.3, 19.0, 17.1, 17.8, 18.5, 17.8, 18.4, 17.9, 18.0,
            17.2, 16.7, 15.8, 17.5, 17.1, 15.0, 15.4, 16.1
          ].map(&:to_s)
        ]
      )
      stub_request(:get, "http://example.com/meterhistory/v2/realtime-data?MPAN=#{meter.mpan_mprn}&fromDate=2024-11-24")
        .to_return(body: File.read('spec/fixtures/perse/meter_history_v2_realtime-data.json'),
                   headers: { 'content-type': 'application/json' })
      log = upserter.perform(meter)
      expect(log.records_updated).to eq(331)
      WebMock.reset!
      stub_request(:get, "http://example.com/meterhistory/v2/realtime-data?MPAN=#{meter.mpan_mprn}&fromDate=2023-10-10")
        .to_return(body: { data: [] }.to_json, headers: { 'content-type': 'application/json' })
      log = upserter.perform(meter, reload: true)
      expect(log.records_updated).to eq(0)
    end

    it 'logs an error' do
      meter = create(:gas_meter)
      stub_request(:get, "http://example.com/meterhistory/v2/realtime-data?MPAN=#{meter.mpan_mprn}&fromDate=2023-10-10")
        .to_return(status: 429)
      log = upserter.perform(meter)
      expect(log.error_messages).not_to be_nil
    end
  end
end
