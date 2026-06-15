require 'rails_helper'

RSpec.describe Schools::Advice::RecentChangesService, type: :service do
  let(:school)                      { create(:school) }

  let(:gas_aggregate_meter)         { double('gas-aggregated-meter', aggregate_meter?: true)}
  let(:electricity_aggregate_meter) { double('electricity-aggregated-meter', aggregate_meter?: true)}

  let(:aggregate_school_service) do
    instance_double(AggregateSchoolService, meter_collection: meter_collection)
  end

  let(:meter_collection) do
    double(:meter_collection, aggregated_heat_meters: gas_aggregate_meter, aggregated_electricity_meters: electricity_aggregate_meter)
  end
  let(:amr_data) { double('amr-data') }

  subject(:service) do
    Schools::Advice::RecentChangesService.new(school: school, aggregate_school_service: aggregate_school_service, fuel_type: :gas)
  end

  before do
    allow(meter_collection).to receive(:aggregate_meter) { gas_aggregate_meter }
    allow(gas_aggregate_meter).to receive(:amr_data).and_return(amr_data)
  end

  describe '#enough_data?' do
    before do
      allow(amr_data).to receive(:start_date).and_return(start_date)
      allow(amr_data).to receive(:end_date).and_return(end_date)
    end

    context 'when there is one full week of data' do
      let(:start_date) { Date.new(2023, 3, 26) }
      let(:end_date)   { Date.new(2023, 4, 1) }

      it 'returns true' do
        expect((start_date..end_date).count).to eq(7)
        expect(start_date.sunday?).to eq(true)
        expect(end_date.saturday?).to eq(true)

        expect(service.enough_data?).to eq(true)
        expect(service.data_available_from).to eq(nil)

        last_week_date_range = service.send(:last_week_date_range)
        previous_week_date_range = service.send(:previous_week_date_range)
        expect(last_week_date_range).to eq([start_date, end_date])
        expect(previous_week_date_range).to eq([])
        expect([last_week_date_range.first.sunday?, last_week_date_range.last.saturday?]).to eq([true, true])
      end
    end

    context 'when there if two full weeks of data' do
      let(:start_date) { Date.new(2023, 3, 19) }
      let(:end_date)   { Date.new(2023, 4, 1) }

      it 'returns true' do
        expect((start_date..end_date).count).to eq(14)

        expect(service.enough_data?).to eq(true)
        expect(service.data_available_from).to eq(nil)

        last_week_date_range = service.send(:last_week_date_range)
        previous_week_date_range = service.send(:previous_week_date_range)
        expect(last_week_date_range).to eq([Date.new(2023, 3, 26), Date.new(2023, 4, 1)])
        expect(previous_week_date_range).to eq([Date.new(2023, 3, 19), Date.new(2023, 3, 25)])
        expect([last_week_date_range.first.sunday?, last_week_date_range.last.saturday?]).to eq([true, true])
        expect([previous_week_date_range.first.sunday?, previous_week_date_range.last.saturday?]).to eq([true, true])
      end
    end

    context 'when there is not a full calendar week of data' do
      let(:start_date) { Date.new(2023, 3, 27) }
      let(:end_date)   { Date.new(2023, 4, 2) }

      it 'returns false' do
        expect((start_date..end_date).count).to eq(7)
        expect(start_date.monday?).to eq(true)
        expect(end_date.sunday?).to eq(true)

        expect(service.enough_data?).to eq(false)
        # This is the next occuring sunday from the last week end date plus 1 week
        expect(service.data_available_from).to eq(Date.new(2023, 4, 9))

        last_week_date_range = service.send(:last_week_date_range)
        previous_week_date_range = service.send(:previous_week_date_range)
        expect(last_week_date_range).to eq([Date.new(2023, 3, 27), Date.new(2023, 4, 1)])
        expect(previous_week_date_range).to eq([])
        expect([last_week_date_range.first.monday?, last_week_date_range.last.saturday?]).to eq([true, true])
      end
    end
  end

  describe '#recent_usage' do
    before do
      allow(amr_data).to receive(:start_date).and_return(start_date)
      allow(amr_data).to receive(:end_date).and_return(end_date)
    end

    let(:recent_usage) { service.recent_usage }

    context 'when there is two full weeks of data' do
      let(:start_date) { Date.new(2023, 3, 19) }
      let(:end_date)   { Date.new(2023, 4, 1) }

      before do
        allow(amr_data).to receive(:kwh_date_range).and_return(1.0)
      end

      it 'returns expected usage' do
        expect(recent_usage.last_week).not_to eq(0.0)
        expect(recent_usage.previous_week).not_to be_nil
        expect(recent_usage.previous_week.date_range).to eq([start_date, start_date + 6])
        expect(recent_usage.change).not_to be_nil
      end
    end

    context 'there is less than 2 weeks of data' do
      let(:end_date)     { Date.new(2023, 12, 11) }
      let(:start_date)   { Date.new(2023, 12, 3) }

      before do
        allow(amr_data).to receive(:kwh_date_range).and_return(1.0)
      end

      it 'returns expected usage' do
        expect(recent_usage.last_week).not_to eq(0.0)
        expect(recent_usage.previous_week).to be_nil
        expect(recent_usage.change).to be_nil
      end
    end
  end
end
