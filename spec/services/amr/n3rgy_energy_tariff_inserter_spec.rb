require 'rails_helper'

describe Amr::N3rgyEnergyTariffInserter do
  let(:school)                      { create(:school) }
  let(:meter)                       { create(:electricity_meter, school: school) }
  let(:start_date)                  { Time.zone.today }
  let(:import_log)                  { create(:tariff_import_log) }

  let(:price)                       { 0.14168 }
  let(:charge)                      { 0.2048 }
  let(:raw_prices)                  { Array.new(48, price) }

  let(:kwh_tariffs)                 {
    {
      start_date => raw_prices
    }
  }
  let(:standing_charges)            {
    { start_date => charge }
  }
  let(:tariff)                     {
    {
      kwh_tariffs: kwh_tariffs,
      standing_charges: standing_charges,
      missing_readings: []
    }
  }

  let(:service)   { Amr::N3rgyEnergyTariffInserter.new(meter: meter, start_date: start_date, tariff: tariff, import_log: import_log) }

  context 'with no existing tariff' do
    let(:energy_tariff)  { EnergyTariff.first }
    let(:prices)         { energy_tariff.energy_tariff_prices }
    let(:charges)        { energy_tariff.energy_tariff_charges }

    before(:each) do
      service.perform
    end

    context 'with flat rate tariff data from n3rgy' do
      it 'creates a new tariff' do
        expect(energy_tariff).to_not be_nil
        expect(energy_tariff.source.to_sym).to eq :dcc
        expect(energy_tariff.enabled).to be true
        expect(energy_tariff.tariff_holder).to eq school
        expect(energy_tariff.meters).to match_array([meter])
        expect(energy_tariff.tariff_type.to_sym).to eq :flat_rate
        expect(energy_tariff.name).to_not be_nil
      end

      it 'creates the prices' do
        expect(prices.count).to eq 1
        expect(prices.first.value).to eq price
      end

      it 'creates the charges' do
        expect(charges.count).to eq 1
        expect(charges.first.charge_type.to_sym).to eq :standing_charge
        expect(charges.first.value).to eq charge
      end
    end

    context 'with differential tariff data from n3rgy' do
      #00:00-06:30, 07:00-23:30
      #which when converted to display is 00:00-07:00, 07:00-00:00
      let(:raw_prices) { Array.new(14, price) + Array.new(34, price * 2)}

      it 'creates a new tariff' do
        expect(energy_tariff.tariff_type.to_sym).to eq :differential
      end
      it 'creates the prices' do
        expect(prices.count).to eq 2
        first = prices.order(start_time: :asc).first
        expect(first.value).to eq price
        expect(first.start_time.strftime('%H:%M')).to eq "00:00"
        expect(first.end_time.strftime('%H:%M')).to eq "07:00"

        last = prices.order(start_time: :asc).last
        expect(last.value).to eq price * 2
        expect(last.start_time.strftime('%H:%M')).to eq "07:00"
        expect(last.end_time.strftime('%H:%M')).to eq "00:00"
      end

      it 'creates the charges' do
        expect(charges.count).to eq 1
        expect(charges.first.charge_type.to_sym).to eq :standing_charge
        expect(charges.first.value).to eq charge
      end
    end
  end

  context 'when there is an unexpected format' do
    #fake up a tiered tariff
    let(:raw_prices) { [{ :tariffs => { 1 => 0.485, 2 => 0.16774 }, :thresholds => { 1 => 1000 }, :type => :tiered }] + Array.new(15, price) + Array.new(32, price * 2)}

    it 'throws an exception' do
      expect{ service.perform }.to raise_error(Amr::N3rgyEnergyTariffInserter::UnexpectedN3rgyTariffError)
    end
  end

  context 'when there are no kwh_tariffs' do
    it 'throws an exception' do
      tariff_without_rates = tariff.merge(kwh_tariffs: {})
      service = Amr::N3rgyEnergyTariffInserter.new(meter: meter, start_date: start_date, tariff: tariff_without_rates, import_log: import_log)
      expect{ service.perform }.to raise_error(Amr::N3rgyEnergyTariffInserter::MissingRatesN3rgyTariffError)
    end
  end

  context 'when the tariff has not changed' do
    let!(:existing_energy_tariff) {
      create(:energy_tariff, :with_flat_price, source: :dcc, school: school, meters: [meter], value: price, end_date: nil)
    }
    let!(:existing_charge) {
      create(:energy_tariff_charge, energy_tariff: existing_energy_tariff, charge_type: :standing_charge, units: :day, value: charge)
    }

    before(:each) do
      service.perform
    end

    it 'does not add a new tariff' do
      expect(EnergyTariff.count).to eq 1
    end

    it 'does not update the existing tariff' do
      existing_energy_tariff.reload
      expect(existing_energy_tariff.end_date).to be_nil
    end

    context 'when the previous tariff has expired' do
      let!(:existing_energy_tariff) {
        create(:energy_tariff, :with_flat_price, source: :dcc, school: school, meters: [meter], value: price, end_date: Date.new(2022,12,1))
      }
      it 'adds a new tariff' do
        expect(EnergyTariff.count).to eq 2
      end
    end

  end

  context 'when the tariff has changed' do
    let(:old_price)   { price }
    let(:old_charge)  { charge }
    let!(:existing_energy_tariff) {
      create(:energy_tariff, :with_flat_price, source: :dcc, school: school, meters: [meter], value: old_price, end_date: nil)
    }
    let!(:existing_charge) {
      create(:energy_tariff_charge, energy_tariff: existing_energy_tariff, charge_type: :standing_charge, units: :day, value: old_charge)
    }

    before(:each) do
      service.perform
    end

    context 'because the standing charge has updated' do
      let(:old_charge)  { 0.1 }
      it 'updates end date of previous tariff' do
        existing_energy_tariff.reload
        expect(existing_energy_tariff.end_date).to eq (Time.zone.today - 1)
      end
      it 'creates a new tariff' do
        expect(EnergyTariff.count).to eq 2
      end
    end

    context 'because the tariff type has changed' do
      #00:00-06:30, 07:00-23:30
      let(:raw_prices) { Array.new(14, price) + Array.new(34, price * 2)}

      it 'updates end date of previous tariff' do
        existing_energy_tariff.reload
        expect(existing_energy_tariff.end_date).to eq (Time.zone.today - 1)
      end

      it 'creates a new tariff' do
        expect(EnergyTariff.count).to eq 2
        expect(EnergyTariff.last.tariff_type.to_sym).to eq :differential
      end
    end

    context 'because the flat rate prices have changed' do
      let(:old_price)  { 0.22 }
      it 'updates end date of previous tariff' do
        existing_energy_tariff.reload
        expect(existing_energy_tariff.end_date).to eq (Time.zone.today - 1)
      end
      it 'creates a new tariff' do
        expect(EnergyTariff.count).to eq 2
      end
    end

    context 'because price in the differential periods has changed' do
      let!(:old_price) { 0.22 }
      #00:00-05:30, 05:30-23:30
      let(:raw_prices) { Array.new(12, old_price) + Array.new(36, old_price * 2)}

      let!(:existing_energy_tariff) {
        create(:energy_tariff, tariff_type: :differential, source: :dcc, school: school, meters: [meter], end_date: nil)
      }
      let!(:existing_period_1) {
        create(:energy_tariff_price, energy_tariff: existing_energy_tariff, value: old_price, units: :kwh, start_time: "00:00", end_time: "07:00")
      }
      let!(:existing_period_2) {
        create(:energy_tariff_price, energy_tariff: existing_energy_tariff, value: old_price, units: :kwh, start_time: "07:00", end_time: "00:00")
      }
      it 'updates end date of previous tariff' do
        existing_energy_tariff.reload
        expect(existing_energy_tariff.end_date).to eq (Time.zone.today - 1)
      end

      it 'creates a new tariff' do
        expect(EnergyTariff.count).to eq 2
      end
    end
    context 'because the differential periods have changed' do
      #00:00-04:30, 05:00-23:30
      let(:raw_prices) { Array.new(10, price) + Array.new(38, price * 2)}

      let!(:existing_energy_tariff) {
        create(:energy_tariff, tariff_type: :differential, source: :dcc, school: school, meters: [meter], end_date: nil)
      }
      let!(:existing_period_1) {
        create(:energy_tariff_price, energy_tariff: existing_energy_tariff, value: old_price, units: :kwh, start_time: "00:00", end_time: "07:00")
      }
      let!(:existing_period_2) {
        create(:energy_tariff_price, energy_tariff: existing_energy_tariff, value: old_price, units: :kwh, start_time: "07:00", end_time: "00:00")
      }
      it 'updates end date of previous tariff' do
        existing_energy_tariff.reload
        expect(existing_energy_tariff.end_date).to eq (Time.zone.today - 1)
      end

      it 'creates a new tariff' do
        expect(EnergyTariff.count).to eq 2
      end
    end

    context 'but the new prices are all zero' do
      let(:old_price) { 0.22 }
      let(:price) { 0.0 }
      it 'does not create a new tariff' do
        expect(EnergyTariff.count).to eq 1
      end
      it 'logs a warning' do
        expect(import_log.error_messages).to_not be_nil
      end
      it 'updates end date of previous tariff' do
        existing_energy_tariff.reload
        expect(existing_energy_tariff.end_date).to eq (Time.zone.today - 1)
      end
    end
  end
end
