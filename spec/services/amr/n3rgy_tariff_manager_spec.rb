require 'rails_helper'

describe Amr::N3rgyTariffManager do
  subject(:service) do
    described_class.new(meter: meter,
      current_n3rgy_tariff: n3rgy_tariff,
      import_log: import_log)
  end

  let(:meter) { create(:electricity_meter) }
  let(:import_log) { create(:tariff_import_log) }

  let(:n3rgy_tariff) { nil }

  context 'when there are no stored tariffs' do
    let(:energy_tariff)  { EnergyTariff.first }
    let(:prices)         { energy_tariff.energy_tariff_prices }
    let(:charges)        { energy_tariff.energy_tariff_charges }

    before do
      service.perform
    end

    context 'with a flat_rate tariff from n3rgy' do
      let(:n3rgy_tariff) do
        {
          standing_charge: 1.25,
          flat_rate: 0.05
        }
      end

      it 'creates a new tariff' do
        expect(energy_tariff).not_to be_nil
        expect(energy_tariff.source.to_sym).to eq :dcc
        expect(energy_tariff.enabled).to be true
        expect(energy_tariff.tariff_holder).to eq meter.school
        expect(energy_tariff.meters).to match_array([meter])
        expect(energy_tariff.tariff_type.to_sym).to eq :flat_rate
        expect(energy_tariff.name).not_to be_nil
      end

      it 'creates the prices' do
        expect(prices.count).to eq 1
        expect(prices.first.value).to eq 0.05
      end

      it 'creates the charges' do
        expect(charges.count).to eq 1
        expect(charges.first.charge_type.to_sym).to eq :standing_charge
        expect(charges.first.value).to eq 1.25
      end
    end

    context 'with a differential tariff from n3rgy' do
      let(:n3rgy_tariff) do
        {
          standing_charge: 1.25,
          differential: [
            { start_time: '00:00', end_time: '07:00', value: 0.05, units: 'kwh' },
            { start_time: '07:00', end_time: '00:00', value: 0.10, units: 'kwh' },
          ]
        }
      end

      it 'creates a new tariff' do
        expect(energy_tariff.tariff_type.to_sym).to eq :differential
      end

      it 'creates the prices' do
        expect(prices.count).to eq 2
        first = prices.order(start_time: :asc).first
        expect(first.value).to eq 0.05
        expect(first.start_time.strftime('%H:%M')).to eq '00:00'
        expect(first.end_time.strftime('%H:%M')).to eq '07:00'

        last = prices.order(start_time: :asc).last
        expect(last.value).to eq 0.10
        expect(last.start_time.strftime('%H:%M')).to eq '07:00'
        expect(last.end_time.strftime('%H:%M')).to eq '00:00'
      end

      it 'creates the charges' do
        expect(charges.count).to eq 1
        expect(charges.first.charge_type.to_sym).to eq :standing_charge
        expect(charges.first.value).to eq 1.25
      end
    end
  end

  context 'when there is a stored tariff' do
    let!(:energy_tariff) do
      create(:energy_tariff, :with_flat_price, source: :dcc, school: meter.school, meters: [meter], value: 0.1, end_date: nil)
    end
    let!(:existing_charge) do
      create(:energy_tariff_charge, energy_tariff: energy_tariff, charge_type: :standing_charge, units: :day, value: 1.25)
    end

    context 'with no valid tariffs from n3rgy' do
      it 'expires the current tariff' do
        service.perform
        energy_tariff.reload
        expect(energy_tariff.end_date).not_to be_nil
      end
    end

    context 'when flat rate tariff has not changed' do
      let(:n3rgy_tariff) do
        {
          standing_charge: 1.25,
          flat_rate: 0.1
        }
      end

      it 'does not expire the tariff' do
        expect { service.perform }.not_to change(EnergyTariff, :count)
        energy_tariff.reload
        expect(energy_tariff.end_date).to be_nil
      end
    end

    context 'when the stored tariff has expired' do
      let!(:energy_tariff) do
        create(:energy_tariff, :with_flat_price, source: :dcc, school: meter.school, meters: [meter], value: 0.1, end_date: Time.zone.today - 2.days)
      end
      let(:n3rgy_tariff) do
        {
          standing_charge: 1.25,
          flat_rate: 0.1
        }
      end

      it 'adds a new tariff' do
        expect { service.perform }.to change(EnergyTariff, :count).by(1)
      end
    end

    context 'when standing charge has changed' do
      let(:n3rgy_tariff) do
        {
          standing_charge: 1.00,
          flat_rate: 0.1
        }
      end

      it 'creates a new tariff' do
        expect { service.perform }.to change(EnergyTariff, :count).by(1)
        energy_tariff.reload
        expect(energy_tariff.end_date).not_to be_nil
      end
    end

    context 'when the type of tariff has changed' do
      let(:n3rgy_tariff) do
        {
          standing_charge: 1.25,
          differential: [
            { start_time: '00:00', end_time: '07:00', value: 0.05, units: 'kwh' },
            { start_time: '07:00', end_time: '00:00', value: 0.10, units: 'kwh' },
          ]
        }
      end

      it 'creates a new tariff' do
        expect { service.perform }.to change(EnergyTariff, :count).by(1)
        energy_tariff.reload
        expect(energy_tariff.end_date).not_to be_nil
      end
    end

    context 'when the differential prices have changed' do
      let!(:existing_energy_tariff) do
        create(:energy_tariff, tariff_type: :differential, source: :dcc, school: meter.school, meters: [meter], end_date: nil)
      end
      let!(:existing_period_1) do
        create(:energy_tariff_price, energy_tariff: existing_energy_tariff, value: 0.44, units: :kwh, start_time: '00:00', end_time: '07:00')
      end
      let!(:existing_period_2) do
        create(:energy_tariff_price, energy_tariff: existing_energy_tariff, value: 0.88, units: :kwh, start_time: '07:00', end_time: '00:00')
      end

      let(:n3rgy_tariff) do
        {
          standing_charge: 1.25,
          differential: [
            { start_time: '00:00', end_time: '07:00', value: 0.05, units: 'kwh' },
            { start_time: '07:00', end_time: '00:00', value: 0.10, units: 'kwh' },
          ]
        }
      end

      it 'creates a new tariff' do
        expect { service.perform }.to change(EnergyTariff, :count).by(1)
        energy_tariff.reload
        expect(energy_tariff.end_date).to be_nil
      end
    end

    context 'when the differential period time ranges have changed' do
      let!(:existing_energy_tariff) do
        create(:energy_tariff, tariff_type: :differential, source: :dcc, school: meter.school, meters: [meter], end_date: nil)
      end
      let!(:existing_period_1) do
        create(:energy_tariff_price, energy_tariff: existing_energy_tariff, value: 0.44, units: :kwh, start_time: '00:00', end_time: '07:00')
      end
      let!(:existing_period_2) do
        create(:energy_tariff_price, energy_tariff: existing_energy_tariff, value: 0.88, units: :kwh, start_time: '07:00', end_time: '00:00')
      end

      let(:n3rgy_tariff) do
        {
          standing_charge: 1.25,
          differential: [
            { start_time: '00:00', end_time: '06:30', value: 0.44, units: 'kwh' },
            { start_time: '06:30', end_time: '00:00', value: 0.88, units: 'kwh' },
          ]
        }
      end

      it 'creates a new tariff' do
        expect { service.perform }.to change(EnergyTariff, :count).by(1)
        energy_tariff.reload
        expect(energy_tariff.end_date).to be_nil
      end
    end

    context 'when the number of differential periods has changed' do
      let!(:existing_energy_tariff) do
        create(:energy_tariff, tariff_type: :differential, source: :dcc, school: meter.school, meters: [meter], end_date: nil)
      end
      let!(:existing_period_1) do
        create(:energy_tariff_price, energy_tariff: existing_energy_tariff, value: 0.44, units: :kwh, start_time: '00:00', end_time: '07:00')
      end
      let!(:existing_period_2) do
        create(:energy_tariff_price, energy_tariff: existing_energy_tariff, value: 0.88, units: :kwh, start_time: '07:00', end_time: '00:00')
      end

      let(:n3rgy_tariff) do
        {
          standing_charge: 1.25,
          differential: [
            { start_time: '00:00', end_time: '04:30', value: 0.44, units: 'kwh' },
            { start_time: '04:30', end_time: '07:00', value: 0.88, units: 'kwh' },
            { start_time: '07:00', end_time: '00:00', value: 0.55, units: 'kwh' },
          ]
        }
      end

      it 'creates a new tariff' do
        expect { service.perform }.to change(EnergyTariff, :count).by(1)
        energy_tariff.reload
        expect(energy_tariff.end_date).to be_nil
      end
    end
  end
end
