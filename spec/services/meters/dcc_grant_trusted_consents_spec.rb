require 'rails_helper'

module Meters
  describe DccGrantTrustedConsents do
    subject(:service) do
      described_class.new([meter], n3rgy_api_factory)
    end

    around do |example|
      ClimateControl.modify FEATURE_FLAG_N3RGY_V2: flag do
        example.run
      end
    end

    let(:meter) { create(:electricity_meter, dcc_meter: true) }
    let(:meter_review) { create(:meter_review, meters: [meter]) }

    context 'with v1' do
      let(:flag) { 'false' }
      let(:n3rgy_api)         { double(:n3rgy_api) }
      let(:n3rgy_api_factory) { double(:n3rgy_api_factory, consent_api: n3rgy_api) }

      it 'calls consent api and set consent_granted flag' do
        expect(n3rgy_api).to receive(:grant_trusted_consent).with(meter.mpan_mprn,
          meter_review.consent_grant.guid).and_return(true)
        service.perform
        expect(meter.reload.consent_granted).to be_truthy
      end

      context 'with v2' do
        let(:flag) { 'true' }

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
  end
end
