require 'rails_helper'

module Meters
  describe DccChecker do

    let(:n3rgy_api)         { double(:n3rgy_api) }
    let(:n3rgy_api_factory) { double(:n3rgy_api_factory, data_api: n3rgy_api) }

    let(:meter)  { create(:electricity_meter, dcc_meter: false) }

    it "should set dcc true and timestamp if found" do
      expect(n3rgy_api).to receive(:status).with(meter.mpan_mprn).and_return(:consent_required)
      Meters::DccChecker.new([meter], n3rgy_api_factory).perform
      expect(meter.reload.dcc_meter).to be_truthy
      expect(meter.reload.dcc_checked_at).not_to be nil
    end

    it "should set timestamp if not found" do
      expect(n3rgy_api).to receive(:status).with(meter.mpan_mprn).and_return(:unknown)
      Meters::DccChecker.new([meter], n3rgy_api_factory).perform
      expect(meter.reload.dcc_meter).to be_falsey
      expect(meter.reload.dcc_checked_at).not_to be nil
    end
  end
end
