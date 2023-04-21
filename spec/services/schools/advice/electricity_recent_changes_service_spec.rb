require 'rails_helper'

RSpec.describe Schools::Advice::ElectricityRecentChangesService, type: :service do

  let(:school) { create(:school) }
  let(:electricity_aggregate_meter)   { double('electricity-aggregated-meter', aggregate_meter?: true)}
  let(:meter_collection) { double(:meter_collection, aggregated_electricity_meters: electricity_aggregate_meter) }
  let(:meter_data_checker) { double(:meter_data_checker) }
  let(:earliest_date) { Date.parse('20220101') }

  let(:service)   { Schools::Advice::ElectricityRecentChangesService.new(school, meter_collection) }

  before do
    allow(service).to receive(:meter_data_checker).and_return(meter_data_checker)
  end

  describe '#at_least_x_full_weeks_of_data?' do
    context 'with at least 2 weeks of data with week starting Sunday' do
      it 'returns true' do
        # 01-04-2023 is a Saturday
        allow(electricity_aggregate_meter).to receive(:amr_data) { OpenStruct.new(start_date: Date.parse('2023-03-19'), end_date: Date.parse('01-04-2023')) }
        expect(electricity_aggregate_meter.amr_data.start_date.sunday?).to eq(true)
        expect(electricity_aggregate_meter.amr_data.end_date.saturday?).to eq(true)
        expect(service.enough_data_for_full_week_comparison?).to eq(true)
      end

      it 'returns false' do
        # 05-04-2023 is a Wednesday
        allow(electricity_aggregate_meter).to receive(:amr_data) { OpenStruct.new(start_date: Date.parse('2023-03-23'), end_date: Date.parse('05-04-2023')) }
        expect(electricity_aggregate_meter.amr_data.start_date.thursday?).to eq(true)
        expect(electricity_aggregate_meter.amr_data.end_date.wednesday?).to eq(true)
        expect(service.enough_data_for_full_week_comparison?).to eq(false)
      end
    end
  end

  describe '#enough_data?' do
    it 'true if the meter data checker returns true' do
      expect(meter_data_checker).to receive(:at_least_x_days_data?).with(7).and_return(true)
      expect(service.enough_data?).to be true
    end
    it 'false if the meter data checker returns false' do
      expect(meter_data_checker).to receive(:at_least_x_days_data?).with(7).and_return(false)
      expect(service.enough_data?).to be false
    end
  end

  describe '#data_available_from' do
    it 'returns date from meter checker' do
      expect(meter_data_checker).to receive(:date_when_enough_data_available).with(7).and_return(earliest_date)
      expect(service.data_available_from).to eq(earliest_date)
    end
  end
end
