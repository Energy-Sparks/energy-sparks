# frozen_string_literal: true

require 'rails_helper'

describe TargetMeter do
  let(:pseudo_meter_attributes) do
    {
      aggregated_electricity: {
        targeting_and_tracking: [{
          start_date: Date.yesterday,
          target: 0.95
        }]
      }
    }
  end

  let(:meter_collection)    { build(:meter_collection, :with_electricity_meter, start_date: Date.today - 400, end_date: Date.yesterday, pseudo_meter_attributes: pseudo_meter_attributes) }
  let(:meter)               { meter_collection.aggregated_electricity_meters }
  let(:calculation_type)    { :day }

  before do
    AggregateDataService.new(meter_collection).aggregate_heat_and_electricity_meters
  end

  describe '.calculation_factory' do
    let(:target_meter) { described_class.calculation_factory(calculation_type, meter) }

    context 'with :day' do
      it 'returns a meter' do
        expect(target_meter).not_to be_nil
      end
    end
  end
end
