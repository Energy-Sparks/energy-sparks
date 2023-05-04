require 'rails_helper'

RSpec.describe Schools::Advice::RecentChangesService, type: :service do

  let(:school) { create(:school) }
  let(:gas_aggregate_meter)   { double('gas-aggregated-meter', aggregate_meter?: true)}
  let(:electricity_aggregate_meter)   { double('electricity-aggregated-meter', aggregate_meter?: true)}
  let(:meter_collection) { double(:meter_collection, aggregated_heat_meters: gas_aggregate_meter, aggregated_electricity_meters: electricity_aggregate_meter) }
  let(:meter_data_checker) { double(:meter_data_checker) }
  let(:earliest_date) { Date.parse('20220101') }
  let(:amr_data)    { double('amr-data') }

  context 'with a gas fuel type' do
    let(:service) do
      Schools::Advice::RecentChangesService.new(school: school, meter_collection: meter_collection, fuel_type: :gas)
    end

    before do
      allow(meter_collection).to receive(:aggregate_meter) { gas_aggregate_meter }
      allow(gas_aggregate_meter).to receive(:amr_data).and_return(amr_data)
      allow(amr_data).to receive(:end_date).and_return(Date.today)
      allow(amr_data).to receive(:start_date).and_return(Date.today - 1.year)
    end

    describe '#enough_data?' do
      it 'returns true if there is at least a full weeks worth of data' do
        start_date = Date.new(2023,3,26)
        end_date = Date.new(2023,4,1)
        expect((start_date..end_date).count).to eq(7)
        expect(start_date.sunday?).to eq(true)
        expect(end_date.saturday?).to eq(true)
        allow(amr_data).to receive(:start_date).and_return(start_date)
        allow(amr_data).to receive(:end_date).and_return(end_date)
        expect(service.enough_data?).to eq(true)
      end

      it 'returns true if there is at least a full weeks worth of data' do
        start_date = Date.new(2023,3,19)
        end_date = Date.new(2023,4,1)
        expect((start_date..end_date).count).to eq(14)
        allow(amr_data).to receive(:start_date).and_return(start_date)
        allow(amr_data).to receive(:end_date).and_return(end_date)
        expect(service.enough_data?).to eq(true)
      end

      it 'returns false if there is no full weeks worth of data' do
        start_date = Date.new(2023,3,27)
        end_date = Date.new(2023,4,2)
        expect((start_date..end_date).count).to eq(7)
        expect(start_date.monday?).to eq(true)
        expect(end_date.sunday?).to eq(true)
        allow(amr_data).to receive(:start_date).and_return(start_date)
        allow(amr_data).to receive(:end_date).and_return(end_date)
        expect(service.enough_data?).to eq(false)
      end
    end
  end

  # context 'with a electricity fuel type' do
  #   let(:service) do
  #     Schools::Advice::RecentChangesService.new(school: school, meter_collection: meter_collection, fuel_type: :electricity)
  #   end
  # end
end
