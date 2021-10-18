require 'rails_helper'

module Cads
  describe LiveDataService do

    let(:school)  { create(:school) }
    let(:cad)     { create(:cad, school: school) }

    before :each do
      expect_any_instance_of(MeterReadingsFeeds::GeoApi).to receive(:login)
    end

    it "triggers fast update if no timestamp returned" do
      response = { 'powerTimestamp' => 0 }
      expect_any_instance_of(MeterReadingsFeeds::GeoApi).to receive(:live_data).with(cad.device_identifier).and_return(response)
      expect_any_instance_of(MeterReadingsFeeds::GeoApi).to receive(:trigger_fast_update).with(cad.device_identifier)
      result = Cads::LiveDataService.new(cad).read
      expect(result).to eq(0.0)
    end

    it "returns power reading" do
      response = { 'powerTimestamp' => 123, 'power' => [{'type' => 'ELECTRICITY', 'watts' => 456}] }
      expect_any_instance_of(MeterReadingsFeeds::GeoApi).to receive(:live_data).with(cad.device_identifier).and_return(response)
      result = Cads::LiveDataService.new(cad).read
      expect(result).to eq(456.0)
    end

    it "handles missing power reading for other type" do
      response = { 'powerTimestamp' => 123, 'power' => [{'type' => 'ELECTRICITY', 'watts' => 456}] }
      expect_any_instance_of(MeterReadingsFeeds::GeoApi).to receive(:live_data).with(cad.device_identifier).and_return(response)
      result = Cads::LiveDataService.new(cad).read(:gas)
      expect(result).to eq(0.0)
    end
  end
end
