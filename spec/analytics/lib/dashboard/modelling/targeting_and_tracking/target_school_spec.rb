# frozen_string_literal: true

require 'rails_helper'

describe TargetSchool do
  let(:pseudo_meter_attributes) { {} }

  let(:meter_collection)    { build(:meter_collection, :with_electricity_meter, pseudo_meter_attributes: pseudo_meter_attributes) }

  let(:calculation_type)    { :day }
  let(:target_school)       { described_class.new(meter_collection, calculation_type) }

  describe '#name' do
    it 'overrides name method' do
      expect(target_school.name).to eq "#{meter_collection.name} : target"
    end
  end

  describe '#aggregated_electricity_meters' do
    let(:meter_collection) { build(:meter_collection, :with_electricity_meter, start_date: Date.today - 400, end_date: Date.yesterday, pseudo_meter_attributes: pseudo_meter_attributes) }

    before do
      AggregateDataService.new(meter_collection).aggregate_heat_and_electricity_meters
    end

    context 'with no target set' do
      it 'returns a nil aggregate meter' do
        expect(target_school.aggregated_electricity_meters).to be_nil
        expect(target_school.reason_for_nil_meter(:electricity)[:text]).to match(TargetSchool::NO_TARGET_SET)
      end
    end

    context 'with target set for electricity' do
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

      it 'calculates a target meter' do
        expect(target_school.aggregated_electricity_meters).not_to be_nil
        expect(target_school.reason_for_nil_meter(:electricity)).to be_nil
      end

      it 'returns nil meter for gas' do
        expect(target_school.aggregated_heat_meters).to be_nil
      end
    end
  end
end
