require 'rails_helper'

describe Database::EnergyTariffMigrationService do

  context '#migrate_user_tariffs' do
    let!(:user_tariff)  do
      UserTariff.create(
        school: create(:school),
        start_date: '2021-04-01',
        end_date: '2022-03-31',
        name: 'My First Tariff',
        fuel_type: :electricity,
        flat_rate: true,
        vat_rate: '20%',
        user_tariff_prices: user_tariff_prices,
        user_tariff_charges: user_tariff_charges,
        )
    end
    let(:user_tariff_price)  { UserTariffPrice.new(start_time: '00:00', end_time: '23:30', value: 1.23, units: 'kwh') }
    let(:user_tariff_charge)  { UserTariffCharge.new(charge_type: :fixed_charge, value: 4.56, units: :month) }

    let(:user_tariff_prices)  { [user_tariff_price] }
    let(:user_tariff_charges)  { [user_tariff_charge] }

    context 'it migrates flat rate tariffs' do
      before do
        Database::EnergyTariffMigrationService.migrate_user_tariffs
      end
      let(:energy_tariff)       { EnergyTariff.first }
      let(:charge)              { energy_tariff.energy_tariff_charges.first }
      let(:price)               { energy_tariff.energy_tariff_prices.first }
      it 'creates energy tariff' do
        expect(energy_tariff.tariff_holder).to eq user_tariff.school
        expect(energy_tariff.start_date).to eq user_tariff.start_date
        expect(energy_tariff.end_date).to eq user_tariff.end_date
        expect(energy_tariff.name).to eq user_tariff.name
        expect(energy_tariff.meter_type).to eq user_tariff.fuel_type
        expect(energy_tariff.tariff_type).to eq "flat_rate"
        expect(energy_tariff.source).to eq "manually_entered"
      end
      it 'creates energy tariff price' do
        expect(price.start_time).to eq user_tariff_price.start_time
        expect(price.end_time).to eq user_tariff_price.end_time
        expect(price.value).to eq user_tariff_price.value
        expect(price.units).to eq user_tariff_price.units
      end
      it 'creates energy tariff charge' do
        expect(charge.charge_type).to eq user_tariff_charge.charge_type
        expect(charge.units).to eq user_tariff_charge.units
        expect(charge.value).to eq user_tariff_charge.value
      end
    end
  end

  context '#migrate_global_meter_attributes' do
    let!(:settings)           { SiteSettings.create! }

    let!(:global_meter_attribute) {
      GlobalMeterAttribute.create(
        attribute_type: 'accounting_tariff',
        meter_types: ["", "gas", "aggregated_gas"],
        input_data: {
            start_date: "01/01/2000",
            end_date: "01/01/2050",
            name: "System Wide Gas Accounting Tariff",
            default: true,
            system_wide: true,
            rates: {
              rate: {
                per: :kwh,
                rate: 0.03
              },
            standing_charge: {
                per: :day,
                rate: 0.6
                }
            }
        }
      )
    }

    context 'migrates the global accounting tariff' do
      let(:energy_tariff)       { EnergyTariff.first }
      let(:charge)              { energy_tariff.energy_tariff_charges.first }
      let(:price)               { energy_tariff.energy_tariff_prices.first }

      before do
        Database::EnergyTariffMigrationService.migrate_global_meter_attributes
      end

      it 'creates energy tariff' do
        expect(energy_tariff.tariff_holder).to eq SiteSettings.current
        expect(energy_tariff.start_date).to eq Date.new(2000,1,1)
        expect(energy_tariff.end_date).to eq Date.new(2050,1,1)
        expect(energy_tariff.name).to eq "System Wide Gas Accounting Tariff"
        expect(energy_tariff.meter_type).to eq "gas"
        expect(energy_tariff.tariff_type).to eq "flat_rate"
        expect(energy_tariff.source).to eq "manually_entered"
      end
      it 'creates energy tariff price' do
        expect(price.start_time.to_s(:time)).to eq '00:00'
        expect(price.end_time.to_s(:time)).to eq '23:30'
        expect(price.value).to eq 0.03
        expect(price.units).to eq "kwh"
      end
      it 'creates energy tariff charge' do
        expect(charge.charge_type).to eq "standing_charge"
        expect(charge.units).to eq "day"
        expect(charge.value).to eq 0.6
      end
    end
  end
end
