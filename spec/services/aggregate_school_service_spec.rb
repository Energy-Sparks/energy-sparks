require 'rails_helper'

describe AggregateSchoolService, type: :service do
  let(:school) { create(:school) }

  let(:electricity_end_date)    { Date.new(2020, 12, 31)}
  let(:electricity_amr_data)    { double('electricity-amr-data') }

  let(:gas_end_date)            { Date.new(2019, 12, 0o1) }
  let(:gas_amr_data)            { double('gas-amr-data') }

  let(:heaters_end_date)        { Date.new(2020, 12, 0o1)}
  let(:heaters_amr_data)        { double('heaters-amr-data') }

  let(:electricity_aggregate_meter) { double('electricity-aggregated-meter')}
  let(:gas_aggregate_meter)     { double('gas-aggregated-meter')}
  let(:heaters_aggregate_meter) { double('heaters-aggregated-meter')}

  let(:meter_collection)        { double('meter-collection') }

  before do
    allow(electricity_amr_data).to receive(:end_date).and_return(electricity_end_date)
    allow(gas_amr_data).to receive(:end_date).and_return(gas_end_date)
    # allow(heaters_amr_data).to receive(:end_date).and_return(heaters_end_date)

    allow(electricity_aggregate_meter).to receive(:amr_data).and_return(electricity_amr_data)
    allow(gas_aggregate_meter).to receive(:amr_data).and_return(gas_amr_data)
    # allow(heaters_aggregate_meter).to receive(:amr_data).and_return(heaters_amr_data)

    allow(meter_collection).to receive(:aggregated_electricity_meters).and_return(electricity_aggregate_meter)
    allow(meter_collection).to receive(:aggregated_heat_meters).and_return(gas_aggregate_meter)
    # allow(meter_collection).to receive(:aggregate_meter).with(:storage_heater).and_return(heaters_aggregate_meter)
  end

  describe '.in_cache?' do
    include_context 'with cache'

    subject(:service) { described_class.new(school) }

    it 'identifies whether meter collection is in cache' do
      expect(service.in_cache?).to be(false)
      service.cache({})
      expect(service.in_cache?).to be(true)
    end
  end

  describe '#analysis_date' do
    it 'returns end date for gas' do
      expect(described_class.analysis_date(meter_collection, :gas)).to eq(gas_end_date)
    end

    it 'returns end date for electricity' do
      expect(described_class.analysis_date(meter_collection, :electricity)).to eq(electricity_end_date)
    end

    it 'returns end date for storage heaters' do
      expect(described_class.analysis_date(meter_collection, :storage_heater)).to eq(electricity_end_date)
    end

    it 'returns today otherwise' do
      expect(described_class.analysis_date(meter_collection, nil)).to eq(Time.zone.today)
      expect(described_class.analysis_date(meter_collection, :solar_pv)).to eq(Time.zone.today)
    end
  end
end
