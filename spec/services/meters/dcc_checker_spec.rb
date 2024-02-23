require 'rails_helper'

module Meters
  describe DccChecker do
    subject(:service) do
      Meters::DccChecker.new([meter], n3rgy_api_factory)
    end

    around do |example|
      ClimateControl.modify FEATURE_FLAG_N3RGY_V2: flag do
        example.run
      end
    end

    let(:meter) { create(:electricity_meter, dcc_meter: false) }

    context 'with v1' do
      let(:flag) {'false'}
      let(:n3rgy_api)         { double(:n3rgy_api) }
      let(:n3rgy_api_factory) { double(:n3rgy_api_factory, data_api: n3rgy_api) }

      context 'when not found' do
        it 'sets timestamp' do
          expect(n3rgy_api).to receive(:find).with(meter.mpan_mprn).and_return(false)
          service.perform
          expect(meter.reload.dcc_meter).to be_falsey
          expect(meter.reload.dcc_checked_at).not_to be nil
        end

        it 'does not generate an email' do
          expect(n3rgy_api).to receive(:find).with(meter.mpan_mprn).and_return(false)
          expect do
            service.perform
          end.not_to change(ActionMailer::Base.deliveries, :count)
        end
      end

      context 'when found' do
        it 'sets dcc true and timestamp if found' do
          expect(n3rgy_api).to receive(:find).with(meter.mpan_mprn).and_return(true)
          service.perform
          expect(meter.reload.dcc_meter).to be_truthy
          expect(meter.reload.dcc_checked_at).not_to be nil
        end

        it 'generates an email if status changed' do
          expect(n3rgy_api).to receive(:find).with(meter.mpan_mprn).and_return(true)
          expect do
            service.perform
          end.to change(ActionMailer::Base.deliveries, :count).from(0).to(1)
        end
      end
    end

    context 'with v2' do
      let(:flag) {'true'}
      let(:n3rgy_api_factory) { nil }

      before do
        allow(DataFeeds::N3rgy::DataApiClient).to receive(:production_client).and_return(n3rgy_data_api_client)
      end

      let(:n3rgy_data_api_client) { double(:n3rgy_data_api_client) }

      context 'when not found' do
        it 'sets timestamp' do
          expect(n3rgy_data_api_client).to receive(:find_mpxn).with(meter.mpan_mprn).and_raise(DataFeeds::N3rgy::NotFound.new)
          service.perform
          expect(meter.reload.dcc_meter).to be_falsey
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
          expect(n3rgy_data_api_client).to receive(:find_mpxn).with(meter.mpan_mprn).and_return(true)
          expect do
            service.perform
          end.to change(ActionMailer::Base.deliveries, :count).from(0).to(1)
        end
      end
    end
  end
end
