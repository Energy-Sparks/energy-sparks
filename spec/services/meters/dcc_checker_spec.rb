require 'rails_helper'

module Meters
  describe DccChecker do
    subject(:service) do
      Meters::DccChecker.new([meter])
    end

    let(:meter) { create(:electricity_meter) }

    before do
      allow(DataFeeds::N3rgy::DataApiClient).to receive(:production_client).and_return(n3rgy_data_api_client)
    end

    let(:n3rgy_data_api_client) { double(:n3rgy_data_api_client) }

    context 'when not found' do
      it 'sets timestamp' do
        expect(n3rgy_data_api_client).to receive(:find_mpxn).with(meter.mpan_mprn).and_raise(DataFeeds::N3rgy::NotFound.new)
        service.perform
        expect(meter.reload.dcc_meter).to eq('no')
        expect(meter.reload.dcc_checked_at).not_to be nil
      end

      it 'does not generate an email' do
        expect(n3rgy_data_api_client).to receive(:find_mpxn).with(meter.mpan_mprn).and_raise(DataFeeds::N3rgy::NotFound.new)
        expect do
          service.perform
        end.not_to change(ActionMailer::Base.deliveries, :count)
      end
    end

    context 'when found' do
      it 'sets dcc true and timestamp if found' do
        expect(n3rgy_data_api_client).to receive(:find_mpxn).with(meter.mpan_mprn).and_return(true)
        service.perform
        expect(meter.reload.dcc_meter).to be_truthy
        expect(meter.reload.dcc_checked_at).not_to be nil
      end

      it 'generates an email if status changed' do
        expect(n3rgy_data_api_client).to receive(:find_mpxn).with(meter.mpan_mprn).and_return({})
        expect { service.perform }.to change(ActionMailer::Base.deliveries, :count).from(0).to(1)
      end
    end
  end
end
