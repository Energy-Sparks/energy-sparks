# frozen_string_literal: true

require 'rails_helper'

describe DccCheckerJob do
  subject(:perform) { described_class.new.perform([meter], 'test@example.com') }

  let(:meter) { create(:electricity_meter) }
  let(:type) { :no }

  before do
    allow(Meters::N3rgyMeteringService).to receive(:new)
      .and_return(instance_double(Meters::N3rgyMeteringService, type:))
  end

  it_behaves_like 'a low priority job' do
    let(:job) { described_class.new }
  end

  context 'with no' do
    it 'sets timestamp' do
      perform
      expect(meter.reload.dcc_meter).to eq('no')
      expect(meter.reload.dcc_checked_at).not_to be_nil
    end

    it 'does not generate an email' do
      expect { perform }.not_to change(ActionMailer::Base.deliveries, :count)
    end
  end

  context 'with smets2' do
    let(:type) { :smets2 }

    it 'sets dcc true and timestamp if found' do
      perform
      expect(meter.reload.dcc_meter).to eq('smets2')
      expect(meter.reload.dcc_checked_at).not_to be_nil
    end

    it 'generates an email if status changed' do
      expect { perform }.to change(ActionMailer::Base.deliveries, :count).from(0).to(1)
    end

    context 'when other' do
      let(:meter) { create(:electricity_meter, dcc_meter: :other) }

      it 'does not generate an email' do
        expect { perform }.not_to change(ActionMailer::Base.deliveries, :count)
      end
    end
  end

  context 'with other' do
    let(:type) { :other }

    context 'when smets2' do
      let(:meter) { create(:electricity_meter, dcc_meter: :smets2) }

      it 'does not generate an email' do
        expect { perform }.not_to change(ActionMailer::Base.deliveries, :count)
      end
    end
  end
end
