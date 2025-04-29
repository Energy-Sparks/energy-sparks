# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Schools::Advice::HeatingControlService, type: :service do
  let(:school) { create(:school) }
  let(:meter_collection) { build(:meter_collection) }
  let(:aggregate_school_service) { instance_double(AggregateSchoolService, meter_collection: meter_collection)}
  let(:service) { described_class.new(school, aggregate_school_service) }

  describe '#meters' do
    context 'when there are gas and electricity meters' do
      let!(:electricity_meter) do
        meter = build(:meter, type: :electricity)
        meter_collection.add_electricity_meter(meter)
        meter
      end

      let!(:gas_meter) do
        meter = build(:meter, type: :gas)
        meter_collection.add_heat_meter(meter)
        meter
      end

      it 'returns only the gas meters' do
        expect(service.meters).to eq([gas_meter])
      end
    end

    context 'when the gas meters have function attributes' do
      let(:gas_meters) { build_list(:meter, 5, type: :gas) }

      before do
        gas_meters.each do |meter|
          meter_collection.add_heat_meter(meter)
        end
        allow(gas_meters[3]).to receive(:non_heating_only?).and_return(true)
        allow(gas_meters[4]).to receive(:non_heating_only?).and_return(true)
      end

      it 'returns only the meters used for heating' do
        expect(service.meters).to contain_exactly(gas_meters[0], gas_meters[1], gas_meters[2])
      end
    end
  end

  describe 'heating_on_in_last_weeks_holiday?' do
    before { travel_to(Date.new(2024, 11, 1)) }

    let(:meter_collection) do
      build(:meter_collection, :with_fuel_and_aggregate_meters, fuel_type: :gas,
                                                                start_date: 1.year.ago.to_date,
                                                                kwh_data_x48: ([1] * 10) + ([2] * 20) + ([1] * 18))
    end

    it 'returns true when not a holiday and a holiday in the previous week' do
      expect(service.heating_on_in_last_weeks_holiday?).to be true
    end

    it 'returns false when a holiday' do
      travel_to(Date.new(2024, 10, 28))
      expect(service.heating_on_in_last_weeks_holiday?).to be false
    end

    it 'returns false when no recent holiday' do
      travel_to(Date.new(2024, 9, 30))
      expect(service.heating_on_in_last_weeks_holiday?).to be false
    end
  end
end
