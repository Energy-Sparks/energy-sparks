require 'rails_helper'

module Amr
  describe N3rgyApiFactory do

    let(:key1)      { 'prod-api-key' }
    let(:url1)      { 'prod-data-url' }

    let(:key2)      { 'sandbox-api-key' }
    let(:url2)      { 'sandbox-data-url' }

    let(:production_meter)  { create(:electricity_meter) }
    let(:sandbox_meter)     { create(:electricity_meter, sandbox: true) }

    around do |example|
      ClimateControl.modify N3RGY_API_KEY: key1, N3RGY_DATA_URL: url1, N3RGY_SANDBOX_API_KEY: key2, N3RGY_SANDBOX_DATA_URL: url2 do
        example.run
      end
    end

    it "should get production api" do
      expect(MeterReadingsFeeds::N3rgyData).to receive(:new).with(api_key: key1, base_url: url1)
      N3rgyApiFactory.new.data_api(production_meter)
    end

    it "should get sandbox api" do
      expect(MeterReadingsFeeds::N3rgyData).to receive(:new).with(api_key: key2, base_url: url2, bad_electricity_standing_charge_units: true)
      N3rgyApiFactory.new.data_api(sandbox_meter)
    end
  end
end
