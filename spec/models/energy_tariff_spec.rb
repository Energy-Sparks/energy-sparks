require 'rails_helper'

describe EnergyTariff do
  let(:tariff_holder)         { create(:school) }
  let(:tariff_type)           { :flat_rate }
  let(:vat_rate)              { 5 }

  let(:energy_tariff_prices)  { [] }
  let(:energy_tariff_charges) { [] }
  let(:meters)                { [] }

  let(:energy_tariff) do
    EnergyTariff.create(
      tariff_holder: tariff_holder,
      start_date: '2021-04-01',
      end_date: '2022-03-31',
      name: 'My First Tariff',
      meter_type: :electricity,
      tariff_type: tariff_type,
      vat_rate: vat_rate,
      energy_tariff_prices: energy_tariff_prices,
      energy_tariff_charges: energy_tariff_charges,
      meters: meters
      )
  end

  context 'validations' do
    let(:energy_tariff_price_1)  { EnergyTariffPrice.new(start_time: '00:00', end_time: '03:30', value: 0.23, units: 'kwh') }
    let(:energy_tariff_price_2)  { EnergyTariffPrice.new(start_time: '04:00', end_time: '23:30', value: 0.46, units: 'kwh') }

    let(:energy_tariff_charge_1)  { EnergyTariffCharge.new(charge_type: :fixed_charge, value: 4.56, units: :month) }
    let(:energy_tariff_charge_2)  { EnergyTariffCharge.new(charge_type: :agreed_availability_charge, value: 6.78, units: :kva) }

    let(:energy_tariff_prices)  { [energy_tariff_price_1, energy_tariff_price_2] }
    let(:energy_tariff_charges) { [energy_tariff_charge_1, energy_tariff_charge_2] }

    context 'with school tariff holder' do
      it 'allows start and end date to both be blank' do
        energy_tariff.update(tariff_holder: create(:school))
        expect(energy_tariff.tariff_holder_type).to eq('School')
        expect(energy_tariff).to be_valid
        energy_tariff.update(start_date: nil, end_date: nil)
        expect(energy_tariff).to be_valid
        expect(energy_tariff.errors.messages).to be_empty
      end
    end

    context 'school group tariff holder' do
      it 'does not allow start and end time to both be blank' do
        energy_tariff.update(tariff_holder: create(:school_group))
        expect(energy_tariff.tariff_holder_type).to eq('SchoolGroup')
        expect(energy_tariff).to be_valid
        energy_tariff.update(start_date: '2021-04-01', end_date: nil)
        expect(energy_tariff).to be_valid
        energy_tariff.update(start_date: nil, end_date: '2021-04-01')
        expect(energy_tariff).to be_valid
        energy_tariff.update(start_date: nil, end_date: nil)
        expect(energy_tariff).not_to be_valid
        expect(energy_tariff.errors.messages).to eq({ end_date: ["start and end date can't both be empty"], start_date: ["start and end date can't both be empty"] })
      end
    end

    context 'site settings tariff holder' do
      it 'allows start and end time to both be blank' do
        energy_tariff.update(tariff_holder: SiteSettings.current)
        expect(energy_tariff.tariff_holder_type).to eq('SiteSettings')
        expect(energy_tariff).to be_valid
        energy_tariff.update(start_date: nil, end_date: nil)
        expect(energy_tariff).to be_valid
        expect(energy_tariff.errors.messages).to be_empty
      end
    end

    it 'does not allow a start date that is greater than an end date' do
      energy_tariff.update(start_date: '2021-04-01', end_date: '2022-03-31')
      expect(energy_tariff).to be_valid
      energy_tariff.update(start_date: '2021-04-01', end_date: '2021-04-01')
      expect(energy_tariff).to be_valid
      energy_tariff.update(start_date: '2022-03-31', end_date: '2021-04-01')
      expect(energy_tariff).not_to be_valid
      expect(energy_tariff.errors.messages).to eq({ start_date: ['start date must be earlier than or equal to end date'] })
    end

    it 'prevents same start and end time' do
      energy_tariff.update(tariff_type: 'differential')
      expect(energy_tariff).to be_valid
      energy_tariff_price_1.update(end_time: energy_tariff_price_1.start_time)
      expect(energy_tariff_price_1).not_to be_valid
      expect(energy_tariff_price_1.errors[:start_time]).to include("can't be the same as end time")
      energy_tariff.update(tariff_type: 'flat_rate')
      energy_tariff_price_1.update(end_time: energy_tariff_price_1.start_time)
      expect(energy_tariff_price_1).to be_valid
    end

    it 'allows end time of one range to be start time of next' do
      expect(energy_tariff).to be_valid
      energy_tariff_price_1.update(end_time: energy_tariff_price_2.start_time)
      expect(energy_tariff_price_1).to be_valid
      expect(energy_tariff).to be_valid
    end

    it 'prevents overlapping start time' do
      expect(energy_tariff).to be_valid
      energy_tariff.update(tariff_type: 'differential')
      energy_tariff_price_2.update(start_time: energy_tariff_price_1.end_time - 1.minute)
      expect(energy_tariff_price_2).not_to be_valid
      expect(energy_tariff_price_2.errors[:start_time]).to include('overlaps with another time range')
    end

    it 'prevents overlapping end time' do
      expect(energy_tariff).to be_valid
      energy_tariff_price_1.update(end_time: energy_tariff_price_2.start_time + 1.minute)
      energy_tariff.update(tariff_type: 'differential')
      expect(energy_tariff_price_1).not_to be_valid
      expect(energy_tariff_price_1.errors[:end_time]).to include('overlaps with another time range')
      energy_tariff.update(tariff_type: 'flat_rate')
      expect(energy_tariff_price_1).to be_valid
    end

    it 'handles midnight end time as next day' do
      expect(energy_tariff).to be_valid
      energy_tariff_price_2.update(start_time: '07:00', end_time: '00:00')
      energy_tariff_price_1.update(start_time: '08:00', end_time: '09:00')
      energy_tariff.update(tariff_type: 'differential')
      expect(energy_tariff_price_1).not_to be_valid
      expect(energy_tariff_price_1.errors.messages).to eq({ end_time: ['overlaps with another time range'], start_time: ['overlaps with another time range'] })
      energy_tariff.update(tariff_type: 'flat_rate')
      expect(energy_tariff_price_1).to be_valid
    end

    it 'requires applies to always be set to both except for electricity meter type tariffs' do
      EnergyTariff.meter_types.each_key do |meter_type|
        energy_tariff.meter_type = meter_type
        EnergyTariff.applies_tos.each_key do |applies_to|
          energy_tariff.applies_to = applies_to
          if meter_type == 'electricity'
            expect(energy_tariff).to be_valid
          elsif applies_to == 'both'
            expect(energy_tariff).to be_valid
          else
            expect(energy_tariff).not_to be_valid
            expect(energy_tariff.errors[:applies_to]).to eq(["applies to must be set to 'both' for all non-electricity tariffs"])
          end
        end
      end
    end

    it { is_expected.to validate_numericality_of(:vat_rate).is_greater_than_or_equal_to(0.0).is_less_than_or_equal_to(100.0).allow_nil }
  end

  describe '.meter_attribute' do
    let(:meter_attribute) { MeterAttribute.to_analytics([energy_tariff.meter_attribute]) }

    it 'creates valid analytics meter attribute' do
      expect(meter_attribute[:accounting_tariff_generic][0][:name]).to eq('My First Tariff')
      expect(meter_attribute[:accounting_tariff_generic][0][:source]).to eq(:manually_entered)
      expect(meter_attribute[:accounting_tariff_generic][0][:type]).to eq(:flat)
      expect(meter_attribute[:accounting_tariff_generic][0][:vat]).to eq(:"5%")
      expect(meter_attribute[:accounting_tariff_generic][0][:tariff_holder]).to eq :school
      expect(meter_attribute[:accounting_tariff_generic][0][:created_at].iso8601).to eq energy_tariff.created_at.to_datetime.iso8601
    end
  end

  describe '.to_hash' do
    let(:attributes) { energy_tariff.to_hash }

    it 'includes basic fields' do
      expect(attributes[:name]).to eq('My First Tariff')
      expect(attributes[:start_date]).to eq('01/04/2021')
      expect(attributes[:end_date]).to eq('31/03/2022')
      expect(attributes[:source]).to eq(:manually_entered)
      expect(attributes[:sub_type]).to eq('')
      expect(attributes[:vat]).to eq('5%')
      expect(attributes[:created_at].iso8601).to eq energy_tariff.created_at.to_datetime.iso8601
    end

    context 'when adding tariff holder' do
      context 'with school' do
        it 'identifies tariff holder' do
          expect(attributes[:tariff_holder]).to eq :school
        end
      end

      context 'when attached to a meter' do
        let(:meters) { [create(:electricity_meter)] }

        it 'identifies tariff holder as a meter' do
          expect(attributes[:tariff_holder]).to eq :meter
        end
      end

      context 'with school_group' do
        let(:tariff_holder) { create(:school_group) }

        it 'identifies tariff holder' do
          expect(attributes[:tariff_holder]).to eq :school_group
        end
      end
    end

    it 'includes ccl' do
      expect(attributes[:climate_change_levy]).to be_falsey

      energy_tariff.update(ccl: true)
      attributes = energy_tariff.to_hash
      expect(attributes[:climate_change_levy]).to be_truthy
    end

    it 'includes tnuos' do
      expect(attributes[:rates][:tnuos]).to be_falsey

      energy_tariff.update(tnuos: true)
      attributes = energy_tariff.to_hash
      expect(attributes[:rates][:tnuos]).to be_truthy
    end

    context 'with nil vat rate' do
      let(:vat_rate) { nil }

      it 'checks for nils' do
        expect(attributes[:vat]).to be_nil
      end
    end

    context 'with flat rate electricity tariff' do
      let(:tariff_type)     { :flat_rate }

      let(:energy_tariff_price)   { EnergyTariffPrice.new(start_time: '00:00', end_time: '23:30', value: 0.23, units: :kwh) }
      let(:energy_tariff_charge)  { EnergyTariffCharge.new(charge_type: :fixed_charge, value: 4.56, units: :month) }

      let(:energy_tariff_prices)  { [energy_tariff_price] }
      let(:energy_tariff_charges) { [energy_tariff_charge] }

      it 'has right type' do
        expect(attributes[:type]).to eq(:flat)
      end

      it 'includes standing charges' do
        rates = attributes[:rates]
        expect(rates[:fixed_charge]).to eq({ per: 'month', rate: '4.56' })
      end

      it 'includes rate' do
        rates = attributes[:rates]
        expect(rates[:flat_rate][:per]).to eq('kwh')
        expect(rates[:flat_rate][:rate]).to eq('0.23')
      end
    end

    context 'with differential electricity tariff' do
      let(:tariff_type) { :differential }

      let(:energy_tariff_price_1)  { EnergyTariffPrice.new(start_time: '00:00', end_time: '03:30', value: 0.23, units: 'kwh') }
      let(:energy_tariff_price_2)  { EnergyTariffPrice.new(start_time: '04:00', end_time: '23:30', value: 0.46, units: 'kwh') }
      let(:energy_tariff_charge_1)  { EnergyTariffCharge.new(charge_type: :fixed_charge, value: 4.56, units: :month) }
      let(:energy_tariff_charge_2)  { EnergyTariffCharge.new(charge_type: :agreed_availability_charge, value: 6.78, units: :kva) }

      let(:energy_tariff_prices)  { [energy_tariff_price_1, energy_tariff_price_2] }
      let(:energy_tariff_charges) { [energy_tariff_charge_1, energy_tariff_charge_2] }

      it 'has right type' do
        expect(attributes[:type]).to eq(:differential)
      end

      it 'includes duos' do
        energy_tariff.energy_tariff_charges << EnergyTariffCharge.create(charge_type: :duos_red, value: 6.78)
        expect(attributes[:rates][:duos_red]).to eq('6.78')
      end

      context 'with asc limit kw' do
        let(:asc_limit_kw_charge) { EnergyTariffCharge.create(charge_type: :asc_limit_kw, value: 5.43) }

        context 'agreed_availability_charge and excess_availability_charge not present' do
          let(:energy_tariff_charges) { [asc_limit_kw_charge] }

          it 'is not included' do
            expect(attributes).not_to have_key(:asc_limit_kw)
          end
        end

        context 'and agreed_availability_charge is present' do
          let(:agreed_availability_charge) { EnergyTariffCharge.create(charge_type: :agreed_availability_charge, value: 6.78, units: :kva) }
          let(:energy_tariff_charges) { [asc_limit_kw_charge, agreed_availability_charge] }

          it 'is included' do
            expect(attributes[:asc_limit_kw]).to eq('5.43')
          end

          it 'includes the charge' do
            expect(attributes[:rates]).to have_key(:agreed_availability_charge)
          end
        end

        context 'and excess_availability_charge is present' do
          let(:excess_availability_charge) { EnergyTariffCharge.create(charge_type: :excess_availability_charge, value: 6.78, units: :kva) }
          let(:energy_tariff_charges) { [asc_limit_kw_charge, excess_availability_charge] }

          it 'is included' do
            expect(attributes[:asc_limit_kw]).to eq('5.43')
          end

          it 'includes the charge' do
            expect(attributes[:rates]).to have_key(:excess_availability_charge)
          end
        end

        context 'only agreed availability charge is present' do
          let(:agreed_availability_charge) { EnergyTariffCharge.create(charge_type: :agreed_availability_charge, value: 6.78, units: :kva) }
          let(:energy_tariff_charges) { [agreed_availability_charge] }

          it 'is not included' do
            expect(attributes[:rates]).not_to have_key(:asc_limit_kw)
          end

          it 'does not include the charge' do
            expect(attributes[:rates]).not_to have_key(:agreed_availability_charge)
          end
        end

        context 'only excess_availability_charge charge is present' do
          let(:excess_availability_charge) { EnergyTariffCharge.create(charge_type: :excess_availability_charge, value: 6.78, units: :kva) }
          let(:energy_tariff_charges) { [excess_availability_charge] }

          it 'is not included' do
            expect(attributes).not_to have_key(:asc_limit_kw)
          end

          it 'does not include the charge' do
            expect(attributes[:rates]).not_to have_key(:excess_availability_charge)
          end
        end

        context 'all charges are present' do
          let(:agreed_availability_charge)  { EnergyTariffCharge.create(charge_type: :agreed_availability_charge, value: 6.78, units: :kva) }
          let(:excess_availability_charge)  { EnergyTariffCharge.create(charge_type: :excess_availability_charge, value: 6.78, units: :kva) }
          let(:energy_tariff_charges) { [asc_limit_kw_charge, agreed_availability_charge, excess_availability_charge] }

          it 'is included' do
            expect(attributes).to have_key(:asc_limit_kw)
          end

          it 'includes the charges' do
            expect(attributes[:rates][:agreed_availability_charge]).to eq({ :per => 'kva', :rate => '6.78' })
            expect(attributes[:rates][:excess_availability_charge]).to eq({ :per => 'kva', :rate => '6.78' })
          end
        end
      end

      it 'includes standing charges' do
        rates = attributes[:rates]
        expect(rates[:fixed_charge]).to eq({ :per => 'month', :rate => '4.56' })
      end

      it 'includes rates with adjusted end times' do
        rates = attributes[:rates]
        expect(rates[:rate0][:per]).to eq('kwh')
        expect(rates[:rate0][:rate]).to eq('0.23')
        expect(rates[:rate0][:from]).to eq({ hour: '00', minutes: '00' })
        expect(rates[:rate0][:to]).to eq({ hour: '03', minutes: '00' })
        expect(rates[:rate1][:per]).to eq('kwh')
        expect(rates[:rate1][:rate]).to eq('0.46')
        expect(rates[:rate1][:from]).to eq({ hour: '04', minutes: '00' })
        expect(rates[:rate1][:to]).to eq({ hour: '23', minutes: '00' })
      end
    end
  end

  describe '#for_schools_in_group' do
    let!(:school_group)     { create(:school_group) }
    let!(:school)           { create(:school, school_group: school_group)}
    let!(:energy_tariff)    { create(:energy_tariff, tariff_holder: school)}
    let!(:energy_tariff_2)  { create(:energy_tariff, tariff_holder: school, enabled: false)}
    let!(:energy_tariff_3)  { create(:energy_tariff)}
    let!(:energy_tariff_4)  { create(:energy_tariff, tariff_holder: school_group)}
    let!(:remove_school_tariff) do
      removed_school = create(:school, school_group: school_group, active: false)
      create(:energy_tariff, tariff_holder: removed_school)
    end

    it 'returns expected schools' do
      expect(EnergyTariff.for_schools_in_group(school.school_group)).to match_array([energy_tariff])
    end
  end

  describe '#count_schools_with_tariff_by_group' do
    let!(:school)           { create(:school, school_group: create(:school_group))}
    let!(:energy_tariff)    { create(:energy_tariff, tariff_holder: school)}
    let!(:energy_tariff_2)  { create(:energy_tariff)}

    it 'returns expected count' do
      expect(EnergyTariff.count_schools_with_tariff_by_group(school.school_group)).to eq 1
    end
  end

  describe '#count_by_school_group' do
    let!(:school_group_1)     { create(:school_group) }
    let!(:school_group_2)     { create(:school_group) }
    let!(:school_group_3)     { create(:school_group) }

    let!(:energy_tariff)      { create(:energy_tariff, tariff_holder: school_group_1)}
    let!(:energy_tariff_2)    { create(:energy_tariff, tariff_holder: school_group_2)}
    let!(:energy_tariff_3)    { create(:energy_tariff, tariff_holder: school_group_2)}

    let(:counts)              { EnergyTariff.count_by_school_group }

    it 'returns expected counts' do
      expect(counts[school_group_1.slug]).to eq 1
      expect(counts[school_group_2.slug]).to eq 2
      expect(counts[school_group_3.slug]).to be_nil
    end
  end

  describe '#usable' do
    before { EnergyTariff.delete_all }

    it 'returns a collection of all usable energy tariffs' do
      flat_rate_energy_tariff = EnergyTariff.create(
        tariff_holder: create(:school),
        start_date: '2021-04-01',
        end_date: '2022-03-31',
        name: 'My First Tariff',
        meter_type: :electricity,
        tariff_type: 'flat_rate',
        vat_rate: 0.1,
        energy_tariff_prices: [],
        energy_tariff_charges: [],
        meters: meters
      )
      differential_energy_tariff = EnergyTariff.create(
        tariff_holder: create(:school),
        start_date: '2021-04-01',
        end_date: '2022-03-31',
        name: 'My First Tariff',
        meter_type: :electricity,
        tariff_type: 'differential',
        vat_rate: 0.1,
        energy_tariff_prices: [],
        energy_tariff_charges: [],
        meters: meters
      )
      expect(EnergyTariff.all.usable).to eq([])
      EnergyTariffPrice.create(start_time: '00:00', end_time: '00:00', value: 0.001, units: 'kwh', energy_tariff: flat_rate_energy_tariff)
      expect(EnergyTariff.all.usable).to eq([flat_rate_energy_tariff])
      EnergyTariffPrice.create(start_time: '00:00', end_time: '12:00', value: 0.001, units: 'kwh', energy_tariff: differential_energy_tariff)
      expect(EnergyTariff.all.usable).to eq([flat_rate_energy_tariff])
      EnergyTariffPrice.create(start_time: '12:00', end_time: '00:00', value: 0.001, units: 'kwh', energy_tariff: differential_energy_tariff)
      expect(EnergyTariff.all.usable).to eq([flat_rate_energy_tariff, differential_energy_tariff])
    end
  end

  describe '#useable?' do
    before { energy_tariff.energy_tariff_prices.delete_all }

    context 'for a flat rate tariff' do
      it 'returns true if an energy tariff has only one energy tariff price record with a value set greater than zero, irrespective of any charges' do
        energy_tariff.update(tariff_type: 'flat_rate')
        expect(energy_tariff).to be_valid
        expect(energy_tariff.energy_tariff_prices.count).to eq(0)
        expect(energy_tariff.usable?).to eq(false)
        energy_tariff_price = EnergyTariffPrice.create(start_time: '00:00', end_time: '00:00', value: nil, units: 'kwh', energy_tariff: energy_tariff)
        expect(energy_tariff.reload.usable?).to eq(false)
        energy_tariff_price.update(value: 0)
        expect(energy_tariff.reload.usable?).to eq(false)
        energy_tariff_price.update(value: 0.0001)
        expect(energy_tariff.reload.usable?).to eq(true)
      end
    end

    context 'for a differential rate tariff' do
      it 'returns true if an energy tariff has 2 or more energy tariff price records with all values set greater than zero and combined start and end times covering a full 24 hour period (1440 minutes), irrespective of any charges' do
        energy_tariff.update(tariff_type: 'differential')
        expect(energy_tariff).to be_valid
        expect(energy_tariff.energy_tariff_prices.count).to eq(0)
        expect(energy_tariff.usable?).to eq(false)
        energy_tariff_price_1 = EnergyTariffPrice.create(start_time: '00:00', end_time: '12:00', value: nil, units: 'kwh', energy_tariff: energy_tariff)
        expect(energy_tariff.reload.usable?).to eq(false)
        energy_tariff_price_2 = EnergyTariffPrice.create(start_time: '12:00', end_time: '00:00', value: nil, units: 'kwh', energy_tariff: energy_tariff)
        expect(energy_tariff.reload.usable?).to eq(false)
        energy_tariff_price_1.update(value: 0)
        energy_tariff_price_2.update(value: 0)
        expect(energy_tariff.reload.usable?).to eq(false)
        energy_tariff_price_1.update(value: 0.001)
        energy_tariff_price_2.update(value: 0.001)
        expect(energy_tariff.reload.usable?).to eq(true)
      end
    end
  end

  describe '.by_start_and_end' do
    let(:energy_tariff_open_start) do
      create(:energy_tariff, tariff_holder: tariff_holder, start_date: nil, end_date: Date.new(2022, 3, 31))
    end
    let(:energy_tariff_open_end) do
      create(:energy_tariff, tariff_holder: tariff_holder, start_date: Date.new(2022, 3, 31), end_date: nil)
    end

    it 'sorts as expected' do
      tariffs = tariff_holder.energy_tariffs.by_start_and_end
      # using eq not match_array as we're expecting exactly this order
      expect(tariffs).to eq([energy_tariff_open_start, energy_tariff, energy_tariff_open_end])
    end
  end
end
