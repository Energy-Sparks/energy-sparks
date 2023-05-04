require 'rails_helper'

RSpec.describe Schools::Advice::RecentChangesService, type: :service do

  let(:school) { create(:school) }
  let(:gas_aggregate_meter)   { double('gas-aggregated-meter', aggregate_meter?: true)}
  let(:electricity_aggregate_meter)   { double('electricity-aggregated-meter', aggregate_meter?: true)}
  let(:meter_collection) { double(:meter_collection, aggregated_heat_meters: gas_aggregate_meter, aggregated_electricity_meters: electricity_aggregate_meter) }
  let(:meter_data_checker) { double(:meter_data_checker) }
  let(:earliest_date) { Date.parse('20220101') }

  context 'with a gas fuel type' do
    let(:service) do
      Schools::Advice::RecentChangesService.new(school: school, meter_collection: meter_collection, fuel_type: :gas)
    end
  end

  context 'with a electricity fuel type' do
    let(:service) do
      Schools::Advice::RecentChangesService.new(school: school, meter_collection: meter_collection, fuel_type: :electricity)
    end
  end
end
