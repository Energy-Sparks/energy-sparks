require 'rails_helper'

RSpec.describe Schools::Advice::HeatingControlService, type: :service do
  let(:school) { create(:school) }
  let(:meter_collection) { double(:meter_collection) }

  let(:service) { Schools::Advice::HeatingControlService.new(school, meter_collection) }

  describe '#meters' do
    context 'when there are gas and electricity meters' do
      let!(:electricity_meter) { create :electricity_meter, name: 'Electricity meter 1', school: school }
      let!(:gas_meter_1) { create :gas_meter, name: 'Gas meter 1', school: school, meter_attributes: []}

      it 'returns only the gas meters' do
        expect(service.meters).to eq([gas_meter_1])
      end
    end

    context 'when the gas meters have function attributes' do
      let!(:gas_meter_1) { create :gas_meter, name: 'Gas meter 1', school: school, meter_attributes: []}
      let!(:gas_meter_2) { create :gas_meter, name: 'Gas meter 2', school: school, meter_attributes: [create(:meter_attribute, :aggregation_switch)] }
      let!(:gas_meter_3) { create :gas_meter, name: 'Gas meter 3', school: school, meter_attributes: [create(:meter_attribute, :heating_only)] }
      let!(:gas_meter_4) { create :gas_meter, name: 'Gas meter 4', school: school, meter_attributes: [create(:meter_attribute, :kitchen_only)] }
      let!(:gas_meter_5) { create :gas_meter, name: 'Gas meter 5', school: school, meter_attributes: [create(:meter_attribute, :hotwater_only)] }

      it 'returns only the meters used for heating' do
        expect(service.meters).to match_array([gas_meter_1, gas_meter_2, gas_meter_3])
      end

      context 'with some old configuration' do
        let!(:gas_meter_6) do
          current = create(:meter_attribute, :heating_only)
          old = create(:meter_attribute, :kitchen_only, replaced_by: current)
          current.update!(replaces: old)
          create :gas_meter, name: 'Gas meter 3', school: school, meter_attributes: [current, old]
        end

        it 'returns only the meters currently used for heating' do
          expect(service.meters).to match_array([gas_meter_1, gas_meter_2, gas_meter_3, gas_meter_6])
        end
      end
    end
  end
end
