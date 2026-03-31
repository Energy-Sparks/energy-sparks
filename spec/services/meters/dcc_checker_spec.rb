# frozen_string_literal: true

require 'rails_helper'

module Meters
  describe DccChecker do
    subject(:perform) { described_class.new([meter]).perform('test@example.com') }

    let(:meter) { create(:electricity_meter) }
    let(:n3rgy_data_api_client) { instance_double(DataFeeds::N3rgy::DataApiClient) }

    before { allow(DataFeeds::N3rgy::DataApiClient).to receive(:production_client).and_return(n3rgy_data_api_client) }

    context 'when not found' do
      it 'sets timestamp' do
        allow(n3rgy_data_api_client).to receive(:find_mpxn).with(meter.mpan_mprn).and_raise(DataFeeds::N3rgy::NotFound.new)
        perform
        expect(meter.reload.dcc_meter).to eq('no')
        expect(meter.reload.dcc_checked_at).not_to be_nil
      end

      it 'does not generate an email' do
        allow(n3rgy_data_api_client).to receive(:find_mpxn).with(meter.mpan_mprn).and_raise(DataFeeds::N3rgy::NotFound.new)
        expect do
          perform
        end.not_to change(ActionMailer::Base.deliveries, :count)
      end
    end

    context 'when found' do
      it 'sets dcc true and timestamp if found' do
        allow(n3rgy_data_api_client).to receive(:find_mpxn).with(meter.mpan_mprn).and_return(true)
        perform
        expect(meter.reload.dcc_meter).to be_truthy
        expect(meter.reload.dcc_checked_at).not_to be_nil
      end

      it 'generates an email if status changed' do
        allow(n3rgy_data_api_client).to receive(:find_mpxn).with(meter.mpan_mprn).and_return({})
        expect { perform }.to change(ActionMailer::Base.deliveries, :count).from(0).to(1)
      end
    end
  end
end
