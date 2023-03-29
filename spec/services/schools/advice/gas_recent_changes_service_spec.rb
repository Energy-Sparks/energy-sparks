require 'rails_helper'

RSpec.describe Schools::Advice::GasRecentChangesService, type: :service do

  let(:school) { create(:school) }
  let(:gas_aggregate_meter)   { double('gas-aggregated-meter', aggregate_meter?: true)}
  let(:meter_collection) { double(:meter_collection, aggregated_heat_meters: gas_aggregate_meter) }
  let(:meter_data_checker) { double(:meter_data_checker) }
  let(:earliest_date) { Date.parse('20220101') }

  let(:service)   { Schools::Advice::GasRecentChangesService.new(school, meter_collection) }

  before do
    allow(service).to receive(:meter_data_checker).and_return(meter_data_checker)
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
