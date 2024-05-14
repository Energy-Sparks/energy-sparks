require 'rails_helper'

module Meters
  describe DccGrantTrustedConsents do
    subject(:service) do
      described_class.new([meter])
    end

    let(:meter) { create(:electricity_meter, dcc_meter: true) }
    let(:meter_review) { create(:meter_review, meters: [meter]) }

    before do
      allow(DataFeeds::N3rgy::ConsentApiClient).to receive(:production_client).and_return(n3rgy_consent_api_client)
    end

    let(:n3rgy_consent_api_client) { double(:n3rgy_consent_api_client) }
    let(:n3rgy_api_factory) { nil }

    it 'calls consent api and set consent_granted flag' do
      expect(n3rgy_consent_api_client).to receive(:add_trusted_consent).with(meter.mpan_mprn,
        meter_review.consent_grant.guid).and_return(true)
      service.perform
      expect(meter.reload.consent_granted).to be_truthy
    end
  end
end
