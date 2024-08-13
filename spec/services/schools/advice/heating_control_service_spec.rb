require 'rails_helper'

RSpec.describe Schools::Advice::HeatingControlService, type: :service do
  let(:school) { create(:school) }
  let(:meter_collection) { build(:meter_collection) }

  let(:service) { Schools::Advice::HeatingControlService.new(school, meter_collection) }

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
        expect(service.meters).to match_array([gas_meters[0], gas_meters[1], gas_meters[2]])
      end
    end
  end
end
