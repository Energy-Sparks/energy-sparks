require 'rails_helper'

module Meters
  describe DccWithdrawTrustedConsents do
    subject(:service) do
      described_class.new([meter])
    end

    let(:meter) { create(:electricity_meter, dcc_meter: true, consent_granted: true) }
    let(:meter_review) { create(:meter_review, meters: [meter]) }

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
