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

  describe '#date_ranges' do
    context 'with at least 2 weeks of data with week starting Sunday' do
      it 'returns an array with date ranges for two full weeks ' do
        # 2023-04-01 is a Saturday, 2023-03-19 is a Sunday
        start_date = Date.new(2023,3,19)
        end_date = Date.new(2023,4,1)
        expect((end_date - start_date) + 1).to eq(14) # Period between start and end dates cover 14 days
        allow(electricity_aggregate_meter).to receive(:amr_data) { OpenStruct.new(start_date: start_date, end_date: end_date) }
        expect(electricity_aggregate_meter.amr_data.start_date.sunday?).to eq(true)
        expect(electricity_aggregate_meter.amr_data.end_date.saturday?).to eq(true)
        date_ranges = service.date_ranges
        expect(date_ranges).to eq(
          {
            last_week: Date.new(2023,3,26)..Date.new(2023,04,01),
            previous_week: Date.new(2023,3,19)..Date.new(2023,3,25)
          }
        )
        expect(date_ranges[:last_week].first.sunday?).to eq(true) # this week start date
        expect(date_ranges[:last_week].last.saturday?).to eq(true) # this week end date
        expect(date_ranges[:previous_week].first.sunday?).to eq(true) # previous week
        expect(date_ranges[:previous_week].last.saturday?).to eq(true) # previous week
      end

      it 'returns an array with date ranges for one full and one (previous) partial week' do
        # 05-04-2023 is a Wednesday, 2023-03-23 is a Thursday
        start_date = Date.new(2023,3,23)
        end_date = Date.new(2023,4,5)
        expect((end_date - start_date) + 1).to eq(14) # Period between start and end dates cover 14 days
        allow(electricity_aggregate_meter).to receive(:amr_data) { OpenStruct.new(start_date: start_date, end_date: end_date) }
        expect(electricity_aggregate_meter.amr_data.start_date.thursday?).to eq(true)
        expect(electricity_aggregate_meter.amr_data.end_date.wednesday?).to eq(true)
        date_ranges = service.date_ranges
        expect(date_ranges).to eq(
          {
            last_week: Date.new(2023,3,26)..Date.new(2023,4,1),
            previous_week: Date.new(2023,3,23)..Date.new(2023,3,25)
          }
        )
        expect(date_ranges[:last_week].first.sunday?).to eq(true) # this week start date
        expect(date_ranges[:last_week].last.saturday?).to eq(true) # this week end date
        expect(date_ranges[:previous_week].first.thursday?).to eq(true) # previous week start date
        expect(date_ranges[:previous_week].last.saturday?).to eq(true) # previous week
      end
    end
  end

  describe '#enough_data?' do
    it 'true if the meter data checker returns true' do
      expect(meter_data_checker).to receive(:at_least_x_days_data?).with(14).and_return(true)
      expect(service.enough_data?).to be true
    end
    it 'false if the meter data checker returns false' do
      expect(meter_data_checker).to receive(:at_least_x_days_data?).with(14).and_return(false)
      expect(service.enough_data?).to be false
    end
  end

  describe '#data_available_from' do
    it 'returns date from meter checker' do
      expect(meter_data_checker).to receive(:date_when_enough_data_available).with(14).and_return(earliest_date)
      expect(service.data_available_from).to eq(earliest_date)
    end
  end
end
