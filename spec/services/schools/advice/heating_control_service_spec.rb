require 'rails_helper'

RSpec.describe Schools::Advice::HeatingControlService, type: :service do
  let(:school) { create(:school) }
  let(:electricity_aggregate_meter)   { double('electricity-aggregated-meter', aggregate_meter?: true)}
  let(:gas_aggregate_meter)   { double('gas-aggregated-meter', aggregate_meter?: true)}
  let(:meter_collection) { double(:meter_collection, school: school, heat_meter: gas_aggregate_meter, aggregated_electricity_meters: electricity_aggregate_meter) }
  let(:service) { Schools::Advice::HeatingControlService.new(school, meter_collection) }

  it 'returns relevent meters' do
    expect(service.meters).to eq([])
  end
end
