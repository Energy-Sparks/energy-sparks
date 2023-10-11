require 'rails_helper'

module Meters
  describe DccWithdrawTrustedConsents do
    let(:n3rgy_api)         { double(:n3rgy_api) }
    let(:n3rgy_api_factory) { double(:n3rgy_api_factory, consent_api: n3rgy_api) }

    let(:meter) { create(:electricity_meter, dcc_meter: true, consent_granted: true) }
    let(:meter_review) { create(:meter_review, meters: [meter]) }

    it 'calls consent api and set consent_granted flag' do
      expect(n3rgy_api).to receive(:withdraw_trusted_consent)
        .with(meter.mpan_mprn)
        .and_return(true)
      Meters::DccWithdrawTrustedConsents.new([meter], n3rgy_api_factory).perform
      expect(meter.reload.consent_granted).to be_falsey
    end

    it 'sets flag even if api raises an error' do
      expect(n3rgy_api).to receive(:withdraw_trusted_consent)
        .with(meter.mpan_mprn)
        .and_raise(MeterReadingsFeeds::N3rgyConsentApi::ConsentFailed.new('No consent found'))
      Meters::DccWithdrawTrustedConsents.new([meter], n3rgy_api_factory).perform
      expect(meter.reload.consent_granted).to be_falsey
    end
  end
end
