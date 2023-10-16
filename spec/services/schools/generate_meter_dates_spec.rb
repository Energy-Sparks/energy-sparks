require 'rails_helper'

describe Schools::GenerateMeterDates, type: :service do
  let(:electricity_start_date)  { Date.new(2020, 0o1, 0o1)}
  let(:electricity_end_date)    { Date.new(2020, 12, 31)}
  let(:electricity_amr_data)    { double('electricity-amr-data') }

  let(:gas_start_date)          { Date.new(2019, 0o1, 0o1)}
  let(:gas_end_date)            { Date.new(2019, 12, 0o1) }
  let(:gas_amr_data)            { double('gas-amr-data') }

  let(:heaters_start_date)      { Date.new(2020, 0o2, 0o1)}
  let(:heaters_end_date)        { Date.new(2020, 12, 0o1)}
  let(:heaters_amr_data)        { double('heaters-amr-data') }

  let(:electricity_aggregate_meter) { double('electricity-aggregated-meter')}
  let(:gas_aggregate_meter)     { double('gas-aggregated-meter')}
  let(:heaters_aggregate_meter) { double('heaters-aggregated-meter')}

  let(:meter_collection)        { double('meter-collection') }

  let(:service) { Schools::GenerateMeterDates.new(meter_collection)}

  before do
    allow(electricity_amr_data).to receive(:start_date).and_return(electricity_start_date)
    allow(electricity_amr_data).to receive(:end_date).and_return(electricity_end_date)

    allow(gas_amr_data).to receive(:start_date).and_return(gas_start_date)
    allow(gas_amr_data).to receive(:end_date).and_return(gas_end_date)

    allow(heaters_amr_data).to receive(:start_date).and_return(heaters_start_date)
    allow(heaters_amr_data).to receive(:end_date).and_return(heaters_end_date)

    allow(electricity_aggregate_meter).to receive(:amr_data).and_return(electricity_amr_data)
    allow(gas_aggregate_meter).to receive(:amr_data).and_return(gas_amr_data)
    allow(heaters_aggregate_meter).to receive(:amr_data).and_return(heaters_amr_data)

    allow(meter_collection).to receive(:aggregate_meter).with(:electricity).and_return(electricity_aggregate_meter)
    allow(meter_collection).to receive(:aggregate_meter).with(:gas).and_return(gas_aggregate_meter)
    allow(meter_collection).to receive(:aggregate_meter).with(:storage_heater).and_return(heaters_aggregate_meter)
  end

  describe '#perform' do
    context 'all fuel types are present' do
      before do
        allow(meter_collection).to receive(:gas?).and_return(true)
        allow(meter_collection).to receive(:electricity?).and_return(true)
        allow(meter_collection).to receive(:storage_heaters?).and_return(true)
      end

      it 'generates expected values' do
        dates = service.generate
        expect(dates[:electricity][:start_date]).to eql("2020-01-01")
        expect(dates[:electricity][:end_date]).to eql("2020-12-31")

        expect(dates[:gas][:start_date]).to eql("2019-01-01")
        expect(dates[:gas][:end_date]).to eql("2019-12-01")

        expect(dates[:storage_heater][:start_date]).to eql("2020-02-01")
        expect(dates[:storage_heater][:end_date]).to eql("2020-12-01")
      end
    end

    context 'has only electricity' do
      before do
        allow(meter_collection).to receive(:gas?).and_return(false)
        allow(meter_collection).to receive(:electricity?).and_return(true)
        allow(meter_collection).to receive(:storage_heaters?).and_return(false)
      end

      it 'generates expected values' do
        dates = service.generate
        expect(dates[:electricity][:start_date]).to eql("2020-01-01")
        expect(dates[:electricity][:end_date]).to eql("2020-12-31")
        expect(dates[:gas]).to be_nil
        expect(dates[:storage_heater]).to be_nil
      end
    end
  end
end
