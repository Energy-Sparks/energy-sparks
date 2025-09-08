# frozen_string_literal: true

require 'rails_helper'

describe Heating::BaseService, type: :service do
  describe '#enough_data?' do
    let(:model)             { double('heating-model') }
    let(:meter_collection)  { build(:meter_collection) }
    let(:meter)             { build(:meter, type: :gas) }

    before do
      meter_collection.add_aggregate_heat_meter(meter)
      allow_any_instance_of(Heating::HeatingModelFactory).to receive(:create_model).and_return(model)
    end

    context 'with valid model' do
      before do
        allow(model).to receive(:enough_samples_for_good_fit).and_return(true)
        allow(model).to receive(:includes_school_day_heating_models?).and_return(true)
      end

      it 'returns true with enough samples' do
        expect(described_class.new(meter_collection, Date.today).enough_data?).to be true
      end
    end
  end

  describe '#validate_meter_collection' do
    context 'with gas meters' do
      let(:meter_collection) { build(:meter_collection) }
      let(:meter) { build(:meter, type: :gas) }

      before do
        meter_collection.add_aggregate_heat_meter(meter)
      end

      it 'accepts the school' do
        described_class.new(meter_collection, Date.today).validate_meter_collection(meter_collection)
      end
    end

    context 'with no gas meters' do
      let(:meter_collection) { build(:meter_collection) }

      it 'rejects the school' do
        expect do
          described_class.new(meter_collection, Date.today).validate_meter_collection(meter_collection)
        end.to raise_error EnergySparksUnexpectedStateException
      end
    end
  end
end
