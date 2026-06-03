# frozen_string_literal: true

require 'rails_helper'

describe Baseload::BaseService, type: :service do
  describe '#validate_meter' do
    context 'with gas meter' do
      let(:meter) { build(:meter, type: :gas) }

      it 'rejects the meter' do
        expect do
          described_class.new.validate_meter(meter)
        end.to raise_error EnergySparksUnexpectedStateException
      end
    end

    context 'with electricity meter' do
      let(:meter) { build(:meter, type: :electricity) }

      it 'accepts the meter' do
        described_class.new.validate_meter(meter)
      end
    end
  end

  describe '#validate_meter_collection' do
    context 'with electricity meters' do
      let(:meter_collection) { build(:meter_collection) }
      let(:meter) { build(:meter, type: :electricity) }

      before do
        meter_collection.update_electricity_meters([meter])
      end

      it 'accepts the school' do
        described_class.new.validate_meter_collection(meter_collection)
      end
    end

    context 'with no electricity meters' do
      let(:meter_collection) { build(:meter_collection) }

      it 'rejects the school' do
        expect do
          described_class.new.validate_meter_collection(meter_collection)
        end.to raise_error EnergySparksUnexpectedStateException
      end
    end
  end
end
