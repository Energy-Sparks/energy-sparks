# frozen_string_literal: true

require 'rails_helper'

describe Amr::PerseUpsert do
  describe '#perform' do
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
      described_class.perform(meter)
      expect(AmrDataFeedReading.where(meter: meter).count).to eq(331)
      stub_request(:get, "http://example.com/meterhistory/v2/realtime-data?MPAN=#{meter.mpan_mprn}&fromDate=2024-12-01")
        .to_return(body: File.read('spec/fixtures/perse/meter_history_v2_realtime-data.json'),
                   headers: { 'content-type': 'application/json' })
      log = described_class.perform(meter)
      expect(log.records_updated).to eq(331)
    end
  end
end
