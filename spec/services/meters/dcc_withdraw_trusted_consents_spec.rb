require 'rails_helper'

module Meters
  describe DccWithdrawTrustedConsents do
    subject(:service) do
      described_class.new([meter], n3rgy_api_factory)
    end

    around do |example|
      ClimateControl.modify FEATURE_FLAG_N3RGY_V2: flag do
        example.run
      end
    end

    let(:meter) { create(:electricity_meter, dcc_meter: true, consent_granted: true) }
    let(:meter_review) { create(:meter_review, meters: [meter]) }

    context 'with v1' do
      let(:flag) { 'false' }
      let(:n3rgy_api)         { double(:n3rgy_api) }
      let(:n3rgy_api_factory) { double(:n3rgy_api_factory, consent_api: n3rgy_api) }

      it 'calls consent api and set consent_granted flag' do
        expect(n3rgy_api).to receive(:withdraw_trusted_consent)
                               .with(meter.mpan_mprn)
                               .and_return(true)
        service.perform
        expect(meter.reload.consent_granted).to be_falsey
      end

      it 'sets flag even if api raises an error' do
        expect(n3rgy_api).to receive(:withdraw_trusted_consent)
                               .with(meter.mpan_mprn)
                               .and_raise(MeterReadingsFeeds::N3rgyConsentApi::ConsentFailed.new('No consent found'))
        service.perform
        expect(meter.reload.consent_granted).to be_falsey
      end
    end

    context 'with v2' do
      let(:flag) { 'true' }
      let(:n3rgy_api_factory) { nil }

      before do
        allow(DataFeeds::N3rgy::ConsentApiClient).to receive(:production_client).and_return(n3rgy_consent_api_client)
      end

      let(:n3rgy_consent_api_client) { double(:n3rgy_consent_api_client) }

      it 'calls consent api and set consent_granted flag' do
        expect(n3rgy_consent_api_client).to receive(:withdraw_consent)
                               .with(meter.mpan_mprn)
                               .and_return(true)
        service.perform
        expect(meter.reload.consent_granted).to be_falsey
      end

      it 'sets flag even if api raises an error' do
        expect(n3rgy_consent_api_client).to receive(:withdraw_consent)
                               .with(meter.mpan_mprn)
                               .and_raise(DataFeeds::N3rgy::ConsentFailure.new('No consent found'))
        service.perform
        expect(meter.reload.consent_granted).to be_falsey
      end
    end
  end
end
