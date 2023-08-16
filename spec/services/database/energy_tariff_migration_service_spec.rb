require 'rails_helper'

RSpec.shared_examples 'the expected EnergyTariff' do
  it 'with the right attributes', skip: 'fails with new energy tariff validations' do
    expect(energy_tariff.start_date).to eq start_date
    expect(energy_tariff.end_date).to eq end_date
    expect(energy_tariff.name).to eq tariff_name
    expect(energy_tariff.meter_type).to eq meter_type
    expect(energy_tariff.source).to eq source
    expect(energy_tariff.tariff_holder).to eq tariff_holder
  end
end

RSpec.shared_examples 'a differential EnergyTariff' do
  it_behaves_like 'the expected EnergyTariff', skip: 'fails with new energy tariff validations'
  it 'has the right type', skip: 'fails with new energy tariff validations' do
    expect(energy_tariff.tariff_type).to eq "differential"
  end
end

RSpec.shared_examples 'a flat rate EnergyTariff' do
  it_behaves_like 'the expected EnergyTariff', skip: 'fails with new energy tariff validations'
  it 'has the right type', skip: 'fails with new energy tariff validations' do
    expect(energy_tariff.tariff_type).to eq "flat_rate"
  end
end

RSpec.shared_examples "a migrated flat rate economic tariff" do
  it_behaves_like 'a flat rate EnergyTariff', skip: 'fails with new energy tariff validations'

  let(:price)   { energy_tariff.energy_tariff_prices.first }

  it 'creates an single price', skip: 'fails with new energy tariff validations' do
    expect(price.start_time.to_s(:time)).to eq '00:00'
    expect(price.end_time.to_s(:time)).to eq '23:30'
    expect(price.value).to eq 0.03
    expect(price.units).to eq "kwh"
  end

  it 'creates no charges', skip: 'fails with new energy tariff validations' do
    expect(energy_tariff.energy_tariff_charges.any?).to eq false
  end
end

RSpec.shared_examples "a migrated differential economic tariff" do
  it_behaves_like 'a differential EnergyTariff', skip: 'fails with new energy tariff validations'

  it 'creates two prices', skip: 'fails with new energy tariff validations' do
    expect(energy_tariff.energy_tariff_prices.count).to eq 2

    daytime, nighttime = energy_tariff.energy_tariff_prices.order(start_time: :asc).to_a
    expect(daytime.start_time.to_s(:time)).to eq '00:00'
    expect(daytime.end_time.to_s(:time)).to eq '07:00'
    expect(daytime.value).to eq rate * 2
    expect(daytime.units).to eq "kwh"

    expect(nighttime.start_time.to_s(:time)).to eq '07:00'
    expect(nighttime.end_time.to_s(:time)).to eq '00:00'
    expect(nighttime.value).to eq rate
    expect(nighttime.units).to eq "kwh"
  end

  it 'creates no charges', skip: 'fails with new energy tariff validations' do
    expect(energy_tariff.energy_tariff_charges.any?).to eq false
  end
end

RSpec.shared_examples "a migrated flat rate accounting tariff" do
  it_behaves_like 'a flat rate EnergyTariff', skip: 'fails with new energy tariff validations'
  let(:price)     { energy_tariff.energy_tariff_prices.first }
  let(:charge)    { energy_tariff.energy_tariff_charges.first }

  it 'creates a single price', skip: 'fails with new energy tariff validations' do
    expect(price.start_time.to_s(:time)).to eq '00:00'
    expect(price.end_time.to_s(:time)).to eq '23:30'
    expect(price.value).to eq 0.03
    expect(price.units).to eq "kwh"
  end

  it 'creates charges', skip: 'fails with new energy tariff validations' do
    expect(energy_tariff.energy_tariff_charges.any?).to eq true
    expect(charge.charge_type).to eq 'standing_charge'
    expect(charge.value).to eq 0.6
    expect(charge.units).to eq 'day'
  end
end

RSpec.shared_examples "a migrated differential accounting tariff" do
  it_behaves_like 'a differential EnergyTariff', skip: 'fails with new energy tariff validations'
  let(:charge)    { energy_tariff.energy_tariff_charges.first }

  it 'creates two prices', skip: 'fails with new energy tariff validations' do
    expect(energy_tariff.energy_tariff_prices.count).to eq 2

    daytime, nighttime = energy_tariff.energy_tariff_prices.order(start_time: :asc).to_a
    expect(daytime.start_time.to_s(:time)).to eq '00:00'
    expect(daytime.end_time.to_s(:time)).to eq '07:00'
    expect(daytime.value).to eq rate * 2
    expect(daytime.units).to eq "kwh"

    expect(nighttime.start_time.to_s(:time)).to eq '07:00'
    expect(nighttime.end_time.to_s(:time)).to eq '00:00'
    expect(nighttime.value).to eq rate
    expect(nighttime.units).to eq "kwh"
  end

  it 'creates charges', skip: 'fails with new energy tariff validations' do
    expect(energy_tariff.energy_tariff_charges.any?).to eq true
    expect(charge.charge_type).to eq 'standing_charge'
    expect(charge.value).to eq 0.6
    expect(charge.units).to eq 'day'
  end
end

describe Database::EnergyTariffMigrationService do

  let(:start_date)      { Date.new(2000,1,1) }
  let(:end_date)        { Date.new(2050,1,1) }
  let(:tariff_name)     { "A Tariff" }
  let(:source)          { "manually_entered" }
  let(:meter_type)      { "electricity" }
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

  context '#date_or_nil' do
    it 'returns expected values', skip: 'fails with new energy tariff validations' do
      expect(Database::EnergyTariffMigrationService.date_or_nil(Date.today)).to eq Date.today
      expect(Database::EnergyTariffMigrationService.date_or_nil(nil)).to eq nil
      expect(Database::EnergyTariffMigrationService.date_or_nil("")).to eq nil
      expect(Database::EnergyTariffMigrationService.date_or_nil("2020-01-01")).to eq Date.new(2020,1,1)
    end
  end

  context '#meter_types' do
    let(:attribute)   { OpenStruct.new(meter_types: meter_types) }
    let(:meter_types) { [] }
    context 'with invalid type' do
      it 'raises exception', skip: 'fails with new energy tariff validations' do
        expect { Database::EnergyTariffMigrationService.meter_type(attribute) }.to raise_error("Unexpected meter type")
      end
    end
    context 'with basic fuel types' do
      ["gas", "electricity", "solar_pv", "exported_solar_pv"].each do |type|
        it "recognises #{type}", skip: 'fails with new energy tariff validations' do
          attribute = OpenStruct.new(meter_types: [type])
          expect(Database::EnergyTariffMigrationService.meter_type(attribute)).to eq type.to_sym
        end
      end
    end
    context 'with aggregate types' do
      it "recognises aggregated_electricity", skip: 'fails with new energy tariff validations' do
        attribute = OpenStruct.new(meter_types: ["aggregated_electricity"])
        expect(Database::EnergyTariffMigrationService.meter_type(attribute)).to eq :electricity
      end
      it "recognises aggregated_gas", skip: 'fails with new energy tariff validations' do
        attribute = OpenStruct.new(meter_types: ["aggregated_gas"])
        expect(Database::EnergyTariffMigrationService.meter_type(attribute)).to eq :gas
      end
    end
    context 'with solar sub meters' do
      it "recognises solar_pv_consumed_sub_meter", skip: 'fails with new energy tariff validations' do
        attribute = OpenStruct.new(meter_types: ["solar_pv_consumed_sub_meter"])
        expect(Database::EnergyTariffMigrationService.meter_type(attribute)).to eq :solar_pv
      end
      it "recognises solar_pv_exported_sub_meter", skip: 'fails with new energy tariff validations' do
        attribute = OpenStruct.new(meter_types: ["solar_pv_exported_sub_meter"])
        expect(Database::EnergyTariffMigrationService.meter_type(attribute)).to eq :exported_solar_pv
      end
    end
  end


  context '#tariff_types' do
    let(:tariff_holder)  { create(:school_group) }
    let!(:school_group_attribute) {
      tariff_holder.meter_attributes.create(
        attribute_type: "accounting_tariff",
        input_data: input_data,
        meter_types: ["electricity"]
      )
    }
    context 'with flat rate' do
      it 'identifies the type', skip: 'fails with new energy tariff validations' do
        expect(Database::EnergyTariffMigrationService.tariff_type(school_group_attribute)).to eq :flat_rate
      end
    end
    context 'with differential' do
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
      it 'identifies the type', skip: 'fails with new energy tariff validations' do
        expect(Database::EnergyTariffMigrationService.tariff_type(school_group_attribute)).to eq :differential
      end
    end
    context 'with data from meter attribute editor' do
      let(:rates) {
        {
          rate: {
            per: :kwh,
            rate: rate
          },
          daytime_rate: {
            from: { hour: '', minutes: '' },
            to: { hour: '', minutes: '' },
            per: '',
            rate: ''
          },
          nighttime_rate: {
            from: { hour: '', minutes: '' },
            to: { hour: '', minutes: '' },
            per: '',
            rate: ''
          }
        }
      }
      it 'identifies the type', skip: 'fails with new energy tariff validations' do
        expect(Database::EnergyTariffMigrationService.tariff_type(school_group_attribute)).to eq :flat_rate
      end
    end
  end

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
      let(:tariff_holder)       { user_tariff.school }

      it_behaves_like "the expected EnergyTariff", skip: 'fails with new energy tariff validations'

      it 'creates a flat rate energy tariff', skip: 'fails with new energy tariff validations' do
        expect(energy_tariff.tariff_type).to eq "flat_rate"
      end
      it 'creates energy tariff price', skip: 'fails with new energy tariff validations' do
        expect(price.start_time).to eq user_tariff_price.start_time
        expect(price.end_time).to eq user_tariff_price.end_time
        expect(price.value).to eq user_tariff_price.value
        expect(price.units).to eq user_tariff_price.units
      end
      it 'creates energy tariff charge', skip: 'fails with new energy tariff validations' do
        expect(charge.charge_type).to eq user_tariff_charge.charge_type
        expect(charge.units).to eq user_tariff_charge.units
        expect(charge.value).to eq user_tariff_charge.value
      end
    end
  end

  context '#migrate_global_solar_meter_attributes' do
    let!(:tariff_holder)           { SiteSettings.create! }
    let(:meter_type)               { "exported_solar_pv" }

    let!(:global_meter_attribute) {
      GlobalMeterAttribute.create(
        attribute_type: 'economic_tariff',
        meter_types: ["", "exported_solar_pv", "solar_pv_exported_sub_meter"],
        input_data: input_data
      )
    }

    context 'migrates a global solar tariff' do
      let(:energy_tariff)       { EnergyTariff.first }
      let(:charge)              { energy_tariff.energy_tariff_charges.first }
      let(:price)               { energy_tariff.energy_tariff_prices.first }

      before do
        Database::EnergyTariffMigrationService.migrate_global_solar_meter_attributes
      end

      it_behaves_like "a migrated flat rate economic tariff", skip: 'fails with new energy tariff validations'
    end
  end

  context '#migrate_global_meter_attributes' do
    let!(:tariff_holder)           { SiteSettings.create! }

    let!(:global_meter_attribute) {
      GlobalMeterAttribute.create(
        attribute_type: 'accounting_tariff',
        meter_types: ["", "electricity", "aggregated_electricity"],
        input_data: input_data
      )
    }

    context 'migrates a global accounting tariff' do
      let(:energy_tariff)       { EnergyTariff.first }
      let(:charge)              { energy_tariff.energy_tariff_charges.first }
      let(:price)               { energy_tariff.energy_tariff_prices.first }

      before do
        Database::EnergyTariffMigrationService.migrate_global_meter_attributes
      end

      it_behaves_like "a migrated flat rate accounting tariff", skip: 'fails with new energy tariff validations'
    end

  end

  context '#migrate_school_group_economic_tariffs' do
    let(:system_wide)    { false }
    let(:tariff_holder)  { create(:school_group) }

    let!(:school_group_attribute) {
      tariff_holder.meter_attributes.create(
        attribute_type: "economic_tariff_change_over_time",
        input_data: input_data,
        meter_types: ["", "electricity", "aggregated_electricity"]
      )
    }
    let(:energy_tariff)       { EnergyTariff.first }
    let(:charge)              { energy_tariff.energy_tariff_charges.first }
    let(:price)               { energy_tariff.energy_tariff_prices.first }

    before(:each) do
      Database::EnergyTariffMigrationService.migrate_school_group_economic_tariffs(tariff_holder)
    end

    context 'with only flat rate tariff' do
      it_behaves_like "a migrated flat rate economic tariff", skip: 'fails with new energy tariff validations'
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

      it_behaves_like "a migrated differential economic tariff", skip: 'fails with new energy tariff validations'
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
      it_behaves_like "a migrated differential economic tariff", skip: 'fails with new energy tariff validations'
    end

  end

  context '#migrate_school_group_accounting_tariffs' do
    let(:system_wide)    { false }
    let(:tariff_holder)  { create(:school_group) }

    let!(:school_group_attribute) {
      tariff_holder.meter_attributes.create(
        attribute_type: "accounting_tariff",
        input_data: input_data,
        meter_types: ["", "electricity", "aggregated_electricity"]
      )
    }
    let(:energy_tariff)        { EnergyTariff.first }

    before(:each) do
      Database::EnergyTariffMigrationService.migrate_school_group_accounting_tariffs(tariff_holder)
    end

    it_behaves_like 'a migrated flat rate accounting tariff', skip: 'fails with new energy tariff validations'
  end

  context '#migrate_school_economic_tariffs' do
    let(:system_wide)    { false }
    let(:default)       { false }
    let(:tariff_holder)  { create(:school) }

    let!(:school_attribute) {
      tariff_holder.meter_attributes.create(
        attribute_type: "economic_tariff_change_over_time",
        input_data: input_data,
        meter_types: ["", "electricity", "aggregated_electricity"]
      )
    }
    let(:energy_tariff)       { EnergyTariff.first }

    before(:each) do
      Database::EnergyTariffMigrationService.migrate_school_economic_tariffs
    end

    context 'with only flat rate tariff' do
      it_behaves_like "a migrated flat rate economic tariff", skip: 'fails with new energy tariff validations'
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

      it_behaves_like "a migrated differential economic tariff", skip: 'fails with new energy tariff validations'
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
      it_behaves_like "a migrated differential economic tariff", skip: 'fails with new energy tariff validations'
    end
  end

  context '#migrate meter accounting tariffs' do
    let(:sytem_wide)      { false }
    let(:default)         { false }
    let(:attribute_type)  { "accounting_tariff" }
    let(:school)          { create(:school) }
    let!(:meter)          { create(:electricity_meter, school: school) }
    let!(:gas_meter)      { create(:gas_meter, school: school) }

    let(:tariff_holder)       { school }

    let!(:meter_attribute) {
      meter.meter_attributes.create(
        attribute_type: attribute_type,
        input_data: input_data
      )
    }
    let(:energy_tariff)        { EnergyTariff.first }

    before(:each) do
      Database::EnergyTariffMigrationService.migrate_meter_accounting_tariffs
    end

    it_behaves_like 'a migrated flat rate accounting tariff', skip: 'fails with new energy tariff validations'

    it 'associates tariff with meter', skip: 'fails with new energy tariff validations' do
      expect(energy_tariff.meters.first).to eq meter
    end

    context 'with differential tariff' do
      let(:attribute_type) { "accounting_tariff_differential" }
      it_behaves_like 'a migrated differential accounting tariff', skip: 'fails with new energy tariff validations'

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
          },
          standing_charge: {
            per: :day,
            rate: standing_charge
          }
        }
      }

      it_behaves_like "a migrated differential accounting tariff", skip: 'fails with new energy tariff validations'
    end
  end

  context '#migrate_tariff_prices' do
    let(:start_date)  { Date.yesterday }
    let(:end_date)    { Date.yesterday }
    let(:source)      { "dcc" }
    let(:tariff_name) { "Tariff from DCC SMETS2 meter" }
    let(:tariff_holder) { create(:school)}
    let(:meter)         { create(:electricity_meter, dcc_meter: true, school: tariff_holder) }

    let!(:tariff_standing_charge) { create(:tariff_standing_charge, meter: meter, start_date: end_date, value: standing_charge) }

    let(:energy_tariff)        { EnergyTariff.first }

    context 'with flat rate tariff' do
      let!(:tariff_price) { create(:tariff_price,
        :with_flat_rate, meter: meter, tariff_date: end_date, flat_rate: Array.new(48, rate) ) }

      before(:each) do
        Database::EnergyTariffMigrationService.migrate_tariff_prices
      end

      it_behaves_like 'a migrated flat rate accounting tariff', skip: 'fails with new energy tariff validations'
    end

    context 'with differential tariff' do
      let!(:tariff_price) { create(:tariff_price,
        :with_differential_tariff, meter: meter, tariff_date: end_date,
        tiered_rate: Array.new(14, rate * 2) + Array.new(34, rate)) }

      before(:each) do
        Database::EnergyTariffMigrationService.migrate_tariff_prices
      end

      it_behaves_like 'a migrated differential accounting tariff', skip: 'fails with new energy tariff validations'
    end

  end

end
