require 'rails_helper'

RSpec.describe Schools::Advice::HeatingControlService, type: :service do
  let(:school) { create(:school) }
  let!(:electricity_meter) { create :electricity_meter, name: "Electricity meter 1", school: school }
  let!(:gas_meter_1) { create :gas_meter, name: "Gas meter 1", school: school, meter_attributes: []}
  let!(:gas_meter_2) { create :gas_meter, name: "Gas meter 2", school: school, meter_attributes: [create(:meter_attribute)] }
  let!(:gas_meter_3) { create :gas_meter, name: "Gas meter 3", school: school, meter_attributes: [create(:meter_attribute, attribute_type: 'function_switch', input_data: 'heating_only')] }
  let!(:gas_meter_4) { create :gas_meter, name: "Gas meter 4", school: school, meter_attributes: [create(:meter_attribute, attribute_type: 'function_switch', input_data: 'kitchen_only')] }
  let!(:gas_meter_5) { create :gas_meter, name: "Gas meter 5", school: school, meter_attributes: [create(:meter_attribute, attribute_type: 'function_switch', input_data: 'hotwater_only')] }

  let(:meter_collection) { double(:meter_collection) }

  let(:service) { Schools::Advice::HeatingControlService.new(school, meter_collection) }

  it 'returns relevent meters' do
    expect(school.meters.count).to eq(6)
    expect(school.meters.gas.count).to eq(5)
    expect(service.meters).to eq([gas_meter_1, gas_meter_2, gas_meter_3])
  end
end
