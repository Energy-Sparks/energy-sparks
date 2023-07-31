require 'rails_helper'

RSpec.shared_examples 'an energy tariff' do
  it 'with right default attributes' do
    expect(energy_tariff.start_date).to eq start_date
    expect(energy_tariff.end_date).to eq end_date
    expect(energy_tariff.name).to eq tariff_name
    expect(energy_tariff.meter_type).to eq "electricity"
    expect(energy_tariff.source).to eq "manually_entered"
    expect(energy_tariff.tariff_holder).to eq subject
  end
end

RSpec.shared_examples "a migrated flat rate economic tariff" do
  it_behaves_like 'an energy tariff'

  it 'creates a flat rate energy tariff' do
    expect(energy_tariff.tariff_type).to eq "flat_rate"
  end

  it 'creates energy tariff price' do
    expect(price.start_time.to_s(:time)).to eq '00:00'
    expect(price.end_time.to_s(:time)).to eq '23:30'
    expect(price.value).to eq 0.03
    expect(price.units).to eq "kwh"
  end

  it 'creates no energy tariff charges' do
    expect(energy_tariff.energy_tariff_charges.any?).to eq false
  end
end

RSpec.shared_examples "a migrated differential economic tariff" do
  it_behaves_like 'an energy tariff'

  it 'the created energy tariff is differential' do
    expect(energy_tariff.tariff_type).to eq "differential"
  end

  it 'creates energy tariff prices' do
    expect(energy_tariff.energy_tariff_prices.count).to eq 2

    daytime, nighttime = energy_tariff.energy_tariff_prices.order(start_time: :asc).to_a
    expect(daytime.start_time.to_s(:time)).to eq '00:00'
    expect(daytime.end_time.to_s(:time)).to eq '06:30'
    expect(daytime.value).to eq rate * 2
    expect(daytime.units).to eq "kwh"

    expect(nighttime.start_time.to_s(:time)).to eq '07:00'
    expect(nighttime.end_time.to_s(:time)).to eq '23:30'
    expect(nighttime.value).to eq rate
    expect(nighttime.units).to eq "kwh"
  end

  it 'creates no energy tariff charges' do
    expect(energy_tariff.energy_tariff_charges.any?).to eq false
  end
end

describe Database::EnergyTariffMigrationService do

  let(:start_date)      { Date.new(2000,1,1) }
  let(:end_date)        { Date.new(2050,1,1) }
  let(:tariff_name)     { "A Tariff" }
  let(:default)         { true }
  let(:system_wide)     { true }
  let(:rate)            { 0.03 }
  let(:standing_charge) { 0.6 }

  let(:rates) {
    {
      rate: {
        per: :kwh,
        rate: rate
      },
      standing_charge: {
        per: :day,
        rate: standing_charge
      }
    }
  }

  let(:input_data)  {
    {
        start_date: start_date,
        end_date: end_date,
        name: tariff_name,
        default: default,
        system_wide: system_wide,
        rates: rates
    }
  }

  context '#migrate_user_tariffs' do
    let!(:user_tariff)  do
      UserTariff.create(
        school: create(:school),
        start_date: start_date,
        end_date: end_date,
        name: tariff_name,
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
      let(:subject)             { user_tariff.school }

      it_behaves_like "an energy tariff"

      it 'creates a flat rate energy tariff' do
        expect(energy_tariff.tariff_type).to eq "flat_rate"
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
    let!(:subject)           { SiteSettings.create! }

    let!(:global_meter_attribute) {
      GlobalMeterAttribute.create(
        attribute_type: 'accounting_tariff',
        meter_types: ["", "electricity", "aggregated_electricity"],
        input_data: input_data
      )
    }

    context 'migrates the global accounting tariff' do
      let(:energy_tariff)       { EnergyTariff.first }
      let(:charge)              { energy_tariff.energy_tariff_charges.first }
      let(:price)               { energy_tariff.energy_tariff_prices.first }

      before do
        Database::EnergyTariffMigrationService.migrate_global_meter_attributes
      end

      it_behaves_like "an energy tariff"

      it 'creates flat rate energy tariff' do
        expect(energy_tariff.tariff_type).to eq "flat_rate"
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

  it 'migrates global solar attributes'

  context '#migrate_school_group_economic_tariffs' do
    let(:sytem_wide)    { false }
    let(:subject)  { create(:school_group) }

    let!(:school_group_attribute) {
      subject.meter_attributes.create(
        school_group: subject,
        attribute_type: "economic_tariff_change_over_time",
        input_data: input_data,
        meter_types: ["", "electricity", "aggregated_electricity"]
      )
    }
    let(:energy_tariff)       { EnergyTariff.first }
    let(:charge)              { energy_tariff.energy_tariff_charges.first }
    let(:price)               { energy_tariff.energy_tariff_prices.first }

    before(:each) do
      Database::EnergyTariffMigrationService.migrate_school_group_economic_tariffs(subject)
    end

    context 'with only flat rate tariff' do
      it_behaves_like "a migrated flat rate economic tariff"
    end

    context 'with differential tariff' do
      let(:rates) {
        {
          daytime_rate: {
            from: { hour: '0', minutes: '0' },
            to: { hour: '7', minutes: '0' },
            per: :kwh,
            rate: rate * 2
          },
          nighttime_rate: {
            from: { hour: '7', minutes: '0' },
            to: { hour: '24', minutes: '0' },
            per: :kwh,
            rate: rate
          }
        }
      }

      it_behaves_like "a migrated differential economic tariff"
    end

    context 'with attribute that both flat and differential rates' do
      let(:rates) {
        {
          rate: {
            per: :kwh,
            rate: 0
          },
          daytime_rate: {
            from: { hour: '0', minutes: '0' },
            to: { hour: '7', minutes: '0' },
            per: :kwh,
            rate: rate * 2
          },
          nighttime_rate: {
            from: { hour: '7', minutes: '0' },
            to: { hour: '24', minutes: '0' },
            per: :kwh,
            rate: rate
          }
        }
      }
      it_behaves_like "a migrated differential economic tariff"
    end

  end

  context '#migrate_school_group_accounting_tariffs' do
    let(:sytem_wide)    { false }
    let(:school_group)  { create(:school_group) }

    let!(:school_group_attribute) {
      school_group.meter_attributes.create(
        school_group: school_group,
        attribute_type: "accounting_tariff",
        input_data: input_data,
        meter_types: ["", "electricity", "aggregated_electricity"]
      )
    }
    let(:energy_tariff)        { EnergyTariff.first }
    let(:charges)              { energy_tariff.energy_tariff_charges }
    let(:prices)               { energy_tariff.energy_tariff_prices }

    before(:each) do
      Database::EnergyTariffMigrationService.migrate_school_group_accounting_tariffs(school_group)
    end

    it 'creates energy tariff' do
      expect(energy_tariff.tariff_holder).to eq school_group
      expect(energy_tariff.start_date).to eq start_date
      expect(energy_tariff.end_date).to eq end_date
      expect(energy_tariff.name).to eq tariff_name
      expect(energy_tariff.meter_type).to eq "electricity"
      expect(energy_tariff.tariff_type).to eq "flat_rate"
      expect(energy_tariff.source).to eq "manually_entered"
    end

    it 'creates energy tariff price' do
      expect(prices.first.start_time.to_s(:time)).to eq '00:00'
      expect(prices.first.end_time.to_s(:time)).to eq '23:30'
      expect(prices.first.value).to eq 0.03
      expect(prices.first.units).to eq "kwh"
    end

    it 'creates energy tariff charges' do
      expect(charges.any?).to eq true
      expect(charges.first.charge_type).to eq 'standing_charge'
      expect(charges.first.value).to eq 0.6
      expect(charges.first.units).to eq 'day'
    end
  end

  context '#migrate_school_economic_tariffs' do
    let(:sytem_wide)    { false }
    let(:default)       { false }
    let(:subject)  { create(:school) }

    let!(:school_attribute) {
      subject.meter_attributes.create(
        school: subject,
        attribute_type: "economic_tariff_change_over_time",
        input_data: input_data,
        meter_types: ["", "electricity", "aggregated_electricity"]
      )
    }
    let(:energy_tariff)       { EnergyTariff.first }
    let(:price)               { energy_tariff.energy_tariff_prices.first }

    before(:each) do
      Database::EnergyTariffMigrationService.migrate_school_economic_tariffs
    end

    context 'with only flat rate tariff' do
      it_behaves_like "a migrated flat rate economic tariff"
    end

    context 'with differential tariff' do
      let(:rates) {
        {
          daytime_rate: {
            from: { hour: '0', minutes: '0' },
            to: { hour: '7', minutes: '0' },
            per: :kwh,
            rate: rate * 2
          },
          nighttime_rate: {
            from: { hour: '7', minutes: '0' },
            to: { hour: '24', minutes: '0' },
            per: :kwh,
            rate: rate
          }
        }
      }

      it_behaves_like "a migrated differential economic tariff"
    end

    context 'with attribute that both flat and differential rates' do
      let(:rates) {
        {
          rate: {
            per: :kwh,
            rate: 0
          },
          daytime_rate: {
            from: { hour: '0', minutes: '0' },
            to: { hour: '7', minutes: '0' },
            per: :kwh,
            rate: rate * 2
          },
          nighttime_rate: {
            from: { hour: '7', minutes: '0' },
            to: { hour: '24', minutes: '0' },
            per: :kwh,
            rate: rate
          }
        }
      }
      it_behaves_like "a migrated differential economic tariff"
    end
  end

end
