require 'rails_helper'

RSpec.describe Schools::Advice::RecentChangesService, type: :service do
  let(:school) { create(:school) }
  let(:gas_aggregate_meter) { double('gas-aggregated-meter', aggregate_meter?: true) }
  let(:electricity_aggregate_meter) { double('electricity-aggregated-meter', aggregate_meter?: true) }
  let(:meter_collection) { double(:meter_collection, aggregated_heat_meters: gas_aggregate_meter, aggregated_electricity_meters: electricity_aggregate_meter) }
  let(:meter_data_checker) { double(:meter_data_checker) }
  let(:earliest_date) { Date.parse('20220101') }
  let(:amr_data) { double('amr-data') }

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

    context 'date handling for data returned by the service' do
      it 'returns true if there is at least a full weeks worth of data' do
        start_date = Date.new(2023, 3, 26)
        end_date = Date.new(2023, 4, 1)
        expect((start_date..end_date).count).to eq(7)
        expect(start_date.sunday?).to eq(true)
        expect(end_date.saturday?).to eq(true)
        allow(amr_data).to receive(:start_date).and_return(start_date)
        allow(amr_data).to receive(:end_date).and_return(end_date)

        last_week_date_range = service.send(:last_week_date_range)
        previous_week_date_range = service.send(:previous_week_date_range)
        expect(last_week_date_range).to eq([Date.new(2023, 3, 26), Date.new(2023, 4, 1)])
        expect(previous_week_date_range).to eq([])
        expect([last_week_date_range.first.sunday?, last_week_date_range.last.saturday?]).to eq([true, true])

        expect(service.enough_data?).to eq(true)
        expect(service.data_available_from).to eq(nil)
      end

      it 'returns true if there is at least a full weeks worth of data' do
        start_date = Date.new(2023, 3, 19)
        end_date = Date.new(2023, 4, 1)
        expect((start_date..end_date).count).to eq(14)
        allow(amr_data).to receive(:start_date).and_return(start_date)
        allow(amr_data).to receive(:end_date).and_return(end_date)

        last_week_date_range = service.send(:last_week_date_range)
        previous_week_date_range = service.send(:previous_week_date_range)
        expect(last_week_date_range).to eq([Date.new(2023, 3, 26), Date.new(2023, 4, 1)])
        expect(previous_week_date_range).to eq([Date.new(2023, 3, 19), Date.new(2023, 3, 25)])
        expect([last_week_date_range.first.sunday?, last_week_date_range.last.saturday?]).to eq([true, true])
        expect([previous_week_date_range.first.sunday?, previous_week_date_range.last.saturday?]).to eq([true, true])

        expect(service.enough_data?).to eq(true)
        expect(service.data_available_from).to eq(nil)
      end

      it 'returns false if there is no full weeks worth of data' do
        start_date = Date.new(2023, 3, 27)
        end_date = Date.new(2023, 4, 2)
        expect((start_date..end_date).count).to eq(7)
        expect(start_date.monday?).to eq(true)
        expect(end_date.sunday?).to eq(true)
        allow(amr_data).to receive(:start_date).and_return(start_date)
        allow(amr_data).to receive(:end_date).and_return(end_date)

        last_week_date_range = service.send(:last_week_date_range)
        previous_week_date_range = service.send(:previous_week_date_range)
        expect(last_week_date_range).to eq([Date.new(2023, 3, 27), Date.new(2023, 4, 1)])
        expect(previous_week_date_range).to eq([])
        expect([last_week_date_range.first.monday?, last_week_date_range.last.saturday?]).to eq([true, true])

        expect(service.enough_data?).to eq(false)
        expect(service.data_available_from).to eq(Date.new(2023, 4, 9)) # This is the next occuring sunday from the last week end date plus 1 week
      end
    end
  end
end
