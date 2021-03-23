require 'rails_helper'

module Meters
  describe DccGrantTrustedConsents do

    let(:n3rgy_api)         { double(:n3rgy_api) }
    let(:n3rgy_api_factory) { double(:n3rgy_api_factory, consent_api: n3rgy_api) }

    let(:meter)  { create(:electricity_meter, dcc_meter: true) }
    let(:meter_review)  { create(:meter_review, meters: [meter]) }

    it "should set call consent api and set consent_granted flag" do
      expect(n3rgy_api).to receive(:grant_trusted_consent).with(meter.mpan_mprn, meter_review.consent_grant.guid).and_return(true)
      Meters::DccGrantTrustedConsents.new([meter], n3rgy_api_factory).perform
      expect(meter.reload.consent_granted).to be_truthy
    end
  end
end
