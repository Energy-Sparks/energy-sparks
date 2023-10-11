require 'rails_helper'

RSpec.shared_examples 'the expected EnergyTariff' do
  it 'with the right attributes' do
    expect(energy_tariff.start_date).to eq start_date
    expect(energy_tariff.end_date).to eq end_date
    expect(energy_tariff.name).to eq tariff_name
    expect(energy_tariff.meter_type).to eq meter_type
    expect(energy_tariff.source).to eq source
    expect(energy_tariff.tariff_holder).to eq tariff_holder
  end
end

RSpec.shared_examples 'a differential EnergyTariff' do
  it_behaves_like 'the expected EnergyTariff'
  it 'has the right type' do
    expect(energy_tariff.tariff_type).to eq 'differential'
  end
end

RSpec.shared_examples 'a flat rate EnergyTariff' do
  it_behaves_like 'the expected EnergyTariff'
  it 'has the right type' do
    expect(energy_tariff.tariff_type).to eq 'flat_rate'
  end
end

RSpec.shared_examples 'a migrated flat rate economic tariff' do
  it_behaves_like 'a flat rate EnergyTariff'

  let(:price) { energy_tariff.energy_tariff_prices.first }

  it 'creates an single price' do
    expect(price.start_time.to_s(:time)).to eq '00:00'
    expect(price.end_time.to_s(:time)).to eq '23:30'
    expect(price.value).to eq 0.03
    expect(price.units).to eq 'kwh'
  end

  it 'creates no charges' do
    expect(energy_tariff.energy_tariff_charges.any?).to eq false
  end
end

RSpec.shared_examples 'a migrated differential economic tariff' do
  it_behaves_like 'a differential EnergyTariff'

  it 'creates two prices' do
    expect(energy_tariff.energy_tariff_prices.count).to eq 2

    daytime, nighttime = energy_tariff.energy_tariff_prices.order(start_time: :asc).to_a
    expect(daytime.start_time.to_s(:time)).to eq '00:00'
    expect(daytime.end_time.to_s(:time)).to eq '07:00'
    expect(daytime.value).to eq rate * 2
    expect(daytime.units).to eq 'kwh'

    expect(nighttime.start_time.to_s(:time)).to eq '07:00'
    expect(nighttime.end_time.to_s(:time)).to eq '00:00'
    expect(nighttime.value).to eq rate
    expect(nighttime.units).to eq 'kwh'
  end

  it 'creates no charges' do
    expect(energy_tariff.energy_tariff_charges.any?).to eq false
  end
end

RSpec.shared_examples 'a migrated flat rate accounting tariff' do
  it_behaves_like 'a flat rate EnergyTariff'
  let(:price)     { energy_tariff.energy_tariff_prices.first }
  let(:charge)    { energy_tariff.energy_tariff_charges.first }

  it 'creates a single price' do
    expect(price.start_time.to_s(:time)).to eq '00:00'
    expect(price.end_time.to_s(:time)).to eq '23:30'
    expect(price.value).to eq 0.03
    expect(price.units).to eq 'kwh'
  end

  it 'creates charges' do
    expect(energy_tariff.energy_tariff_charges.any?).to eq true
    expect(charge.charge_type).to eq 'standing_charge'
    expect(charge.value).to eq 0.6
    expect(charge.units).to eq 'day'
  end
end

RSpec.shared_examples 'a migrated differential accounting tariff' do
  it_behaves_like 'a differential EnergyTariff'
  let(:charge)    { energy_tariff.energy_tariff_charges.first }

  it 'creates two prices' do
    expect(energy_tariff.energy_tariff_prices.count).to eq 2

    daytime, nighttime = energy_tariff.energy_tariff_prices.order(start_time: :asc).to_a
    expect(daytime.start_time.to_s(:time)).to eq '00:00'
    expect(daytime.end_time.to_s(:time)).to eq '07:00'
    expect(daytime.value).to eq rate * 2
    expect(daytime.units).to eq 'kwh'

    expect(nighttime.start_time.to_s(:time)).to eq '07:00'
    expect(nighttime.end_time.to_s(:time)).to eq '00:00'
    expect(nighttime.value).to eq rate
    expect(nighttime.units).to eq 'kwh'
  end

  it 'creates charges' do
    expect(energy_tariff.energy_tariff_charges.any?).to eq true
    expect(charge.charge_type).to eq 'standing_charge'
    expect(charge.value).to eq 0.6
    expect(charge.units).to eq 'day'
  end
end

describe Database::EnergyTariffMigrationService do
  let(:start_date)      { Date.new(2000, 1, 1) }
  let(:end_date)        { Date.new(2050, 1, 1) }
  let(:tariff_name)     { 'A Tariff' }
  let(:source)          { 'manually_entered' }
  let(:meter_type)      { 'electricity' }
  let(:default)         { true }
  let(:system_wide)     { true }
  let(:rate)            { 0.03 }
  let(:standing_charge) { 0.6 }

  let(:rates) do
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
  end

  let(:input_data) do
    {
      start_date: start_date,
      end_date: end_date,
      name: tariff_name,
      default: default,
      system_wide: system_wide,
      rates: rates
    }
  end

  describe '#date_or_nil' do
    it 'returns expected values' do
      expect(Database::EnergyTariffMigrationService.date_or_nil(Date.today)).to eq Date.today
      expect(Database::EnergyTariffMigrationService.date_or_nil(nil)).to eq nil
      expect(Database::EnergyTariffMigrationService.date_or_nil('')).to eq nil
      expect(Database::EnergyTariffMigrationService.date_or_nil('2020-01-01')).to eq Date.new(2020, 1, 1)
    end
  end

  describe '#meter_types' do
    let(:attribute)   { OpenStruct.new(meter_types: meter_types) }
    let(:meter_types) { [] }

    context 'with invalid type' do
      it 'raises exception' do
        expect { Database::EnergyTariffMigrationService.meter_type(attribute) }.to raise_error('Unexpected meter type')
      end
    end

    context 'with basic fuel types' do
      %w[gas electricity solar_pv exported_solar_pv].each do |type|
        it "recognises #{type}" do
          attribute = OpenStruct.new(meter_types: [type])
          expect(Database::EnergyTariffMigrationService.meter_type(attribute)).to eq type.to_sym
        end
      end
    end

    context 'with aggregate types' do
      it 'recognises aggregated_electricity' do
        attribute = OpenStruct.new(meter_types: ['aggregated_electricity'])
        expect(Database::EnergyTariffMigrationService.meter_type(attribute)).to eq :electricity
      end

      it 'recognises aggregated_gas' do
        attribute = OpenStruct.new(meter_types: ['aggregated_gas'])
        expect(Database::EnergyTariffMigrationService.meter_type(attribute)).to eq :gas
      end
    end

    context 'with solar sub meters' do
      it 'recognises solar_pv_consumed_sub_meter' do
        attribute = OpenStruct.new(meter_types: ['solar_pv_consumed_sub_meter'])
        expect(Database::EnergyTariffMigrationService.meter_type(attribute)).to eq :solar_pv
      end

      it 'recognises solar_pv_exported_sub_meter' do
        attribute = OpenStruct.new(meter_types: ['solar_pv_exported_sub_meter'])
        expect(Database::EnergyTariffMigrationService.meter_type(attribute)).to eq :exported_solar_pv
      end
    end
  end

  describe '#tariff_types' do
    let(:tariff_holder) { create(:school_group) }
    let!(:school_group_attribute) do
      tariff_holder.meter_attributes.create(
        attribute_type: 'accounting_tariff',
        input_data: input_data,
        meter_types: ['electricity']
      )
    end

    context 'with flat rate' do
      it 'identifies the type' do
        expect(Database::EnergyTariffMigrationService.tariff_type(school_group_attribute)).to eq :flat_rate
      end
    end

    context 'with differential' do
      let(:rates) do
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
      end

      it 'identifies the type' do
        expect(Database::EnergyTariffMigrationService.tariff_type(school_group_attribute)).to eq :differential
      end
    end

    context 'with data from meter attribute editor' do
      let(:rates) do
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
      end

      it 'identifies the type' do
        expect(Database::EnergyTariffMigrationService.tariff_type(school_group_attribute)).to eq :flat_rate
      end
    end
  end

  describe '#migrate_global_solar_meter_attributes' do
    let!(:tariff_holder)           { SiteSettings.create! }
    let(:meter_type)               { 'exported_solar_pv' }

    let!(:global_meter_attribute) do
      GlobalMeterAttribute.create(
        attribute_type: 'economic_tariff',
        meter_types: ['', 'exported_solar_pv', 'solar_pv_exported_sub_meter'],
        input_data: input_data
      )
    end

    context 'migrates a global solar tariff' do
      let(:energy_tariff)       { EnergyTariff.first }
      let(:charge)              { energy_tariff.energy_tariff_charges.first }
      let(:price)               { energy_tariff.energy_tariff_prices.first }

      before do
        Database::EnergyTariffMigrationService.migrate_global_solar_meter_attributes
      end

      it_behaves_like 'a migrated flat rate economic tariff'
    end
  end

  describe '#migrate_global_meter_attributes' do
    let!(:tariff_holder) { SiteSettings.create! }

    let!(:global_meter_attribute) do
      GlobalMeterAttribute.create(
        attribute_type: 'accounting_tariff',
        meter_types: ['', 'electricity', 'aggregated_electricity'],
        input_data: input_data
      )
    end

    context 'migrates a global accounting tariff' do
      let(:energy_tariff)       { EnergyTariff.first }
      let(:charge)              { energy_tariff.energy_tariff_charges.first }
      let(:price)               { energy_tariff.energy_tariff_prices.first }

      before do
        Database::EnergyTariffMigrationService.migrate_global_meter_attributes
      end

      it_behaves_like 'a migrated flat rate accounting tariff'
    end
  end

  describe '#migrate_school_group_economic_tariffs' do
    let(:system_wide)    { false }
    let(:tariff_holder)  { create(:school_group) }

    let!(:school_group_attribute) do
      tariff_holder.meter_attributes.create(
        attribute_type: 'economic_tariff_change_over_time',
        input_data: input_data,
        meter_types: ['', 'electricity', 'aggregated_electricity']
      )
    end
    let(:energy_tariff)       { EnergyTariff.first }
    let(:charge)              { energy_tariff.energy_tariff_charges.first }
    let(:price)               { energy_tariff.energy_tariff_prices.first }

    before do
      Database::EnergyTariffMigrationService.migrate_school_group_economic_tariffs(tariff_holder)
    end

    context 'with only flat rate tariff' do
      it_behaves_like 'a migrated flat rate economic tariff'
    end

    context 'with differential tariff' do
      let(:rates) do
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
      end

      it_behaves_like 'a migrated differential economic tariff'
    end

    context 'with attribute that both flat and differential rates' do
      let(:rates) do
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
      end

      it_behaves_like 'a migrated differential economic tariff'
    end
  end

  describe '#migrate_school_group_accounting_tariffs' do
    let(:system_wide)    { false }
    let(:tariff_holder)  { create(:school_group) }

    let!(:school_group_attribute) do
      tariff_holder.meter_attributes.create(
        attribute_type: 'accounting_tariff',
        input_data: input_data,
        meter_types: ['', 'electricity', 'aggregated_electricity']
      )
    end
    let(:energy_tariff) { EnergyTariff.first }

    before do
      Database::EnergyTariffMigrationService.migrate_school_group_accounting_tariffs(tariff_holder)
    end

    it_behaves_like 'a migrated flat rate accounting tariff'
  end

  describe '#migrate_school_economic_tariffs' do
    let(:system_wide) { false }
    let(:default) { false }
    let(:tariff_holder) { create(:school) }

    let!(:school_attribute) do
      tariff_holder.meter_attributes.create(
        attribute_type: 'economic_tariff_change_over_time',
        input_data: input_data,
        meter_types: ['', 'electricity', 'aggregated_electricity']
      )
    end
    let(:energy_tariff) { EnergyTariff.first }

    before do
      Database::EnergyTariffMigrationService.migrate_school_economic_tariffs
    end

    context 'with only flat rate tariff' do
      it_behaves_like 'a migrated flat rate economic tariff'
    end

    context 'with differential tariff' do
      let(:rates) do
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
      end

      it_behaves_like 'a migrated differential economic tariff'
    end

    context 'with attribute that both flat and differential rates' do
      let(:rates) do
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
      end

      it_behaves_like 'a migrated differential economic tariff'
    end
  end

  describe '#migrate meter accounting tariffs' do
    let(:sytem_wide)      { false }
    let(:default)         { false }
    let(:attribute_type)  { 'accounting_tariff' }
    let(:school)          { create(:school) }
    let!(:meter)          { create(:electricity_meter, school: school) }
    let!(:gas_meter)      { create(:gas_meter, school: school) }

    let(:tariff_holder) { school }

    let!(:meter_attribute) do
      meter.meter_attributes.create(
        attribute_type: attribute_type,
        input_data: input_data
      )
    end
    let(:energy_tariff) { EnergyTariff.first }

    before do
      Database::EnergyTariffMigrationService.migrate_meter_accounting_tariffs
    end

    it_behaves_like 'a migrated flat rate accounting tariff'

    it 'associates tariff with meter' do
      expect(energy_tariff.meters.first).to eq meter
    end

    context 'with differential tariff' do
      let(:attribute_type) { 'accounting_tariff_differential' }
      let(:rates) do
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
      end
      let(:rates) do
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
      end

      it_behaves_like 'a migrated differential accounting tariff'

      it_behaves_like 'a migrated differential accounting tariff'
    end
  end
end
