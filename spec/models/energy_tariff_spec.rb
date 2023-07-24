require 'rails_helper'

describe EnergyTariff do

  let(:school) { create(:school) }

  context 'with only basic fields' do

    let(:energy_tariff)  do
      EnergyTariff.create(
        tariff_holder: school,
        start_date: '2021-04-01',
        end_date: '2022-03-31',
        name: 'My Empty Tariff',
        source: :manually_entered,
        meter_type: :electricity,
        tariff_type: :flat_rate,
        vat_rate: 0,
        )
    end

    it "should create valid analytics meter attribute" do
      meter_attribute = MeterAttribute.to_analytics([energy_tariff.meter_attribute])

      expect(meter_attribute[:accounting_tariff_generic][0][:name]).to eq('My Empty Tariff')
      expect(meter_attribute[:accounting_tariff_generic][0][:source]).to eq(:manually_entered)
      expect(meter_attribute[:accounting_tariff_generic][0][:type]).to eq(:flat)
      expect(meter_attribute[:accounting_tariff_generic][0][:vat]).to eq(:"0%")
    end
  end

  context 'with flat rate electricity tariff' do

    let(:energy_tariff)  do
      EnergyTariff.create(
        tariff_holder: school,
        start_date: '2021-04-01',
        end_date: '2022-03-31',
        name: 'My First Tariff',
        meter_type: :electricity,
        tariff_type: :flat_rate,
        source: :manually_entered,
        vat_rate: 20,
        energy_tariff_prices: energy_tariff_prices,
        energy_tariff_charges: energy_tariff_charges,
        created_by: nil,
        updated_by: nil
        )
    end
    let(:attributes) { energy_tariff.to_hash }

    let(:energy_tariff_price)  { EnergyTariffPrice.new(start_time: '00:00', end_time: '23:30', value: 1.23, units: :kwh) }
    let(:energy_tariff_charge)  { EnergyTariffCharge.new(charge_type: :fixed_charge, value: 4.56, units: :month) }

    let(:energy_tariff_prices)  { [energy_tariff_price] }
    let(:energy_tariff_charges)  { [energy_tariff_charge] }

    it "should include basic fields" do
      expect(attributes[:name]).to eq('My First Tariff')
      expect(attributes[:start_date]).to eq('01/04/2021')
      expect(attributes[:end_date]).to eq('31/03/2022')
      expect(attributes[:source]).to eq(:manually_entered)
      expect(attributes[:type]).to eq(:flat)
      expect(attributes[:sub_type]).to eq('')
      expect(attributes[:vat]).to eq('20%')
    end

    it "should include standing charges" do
      rates = attributes[:rates]
      expect(rates[:fixed_charge]).to eq({per: 'month', rate: '4.56'})
    end

    it "should include rate" do
      rates = attributes[:rates]
      expect(rates[:flat_rate][:per]).to eq('kwh')
      expect(rates[:flat_rate][:rate]).to eq('1.23')
    end

    it "should create valid analytics meter attribute" do
      meter_attribute = MeterAttribute.to_analytics([energy_tariff.meter_attribute])

      expect(meter_attribute[:accounting_tariff_generic][0][:name]).to eq('My First Tariff')
      expect(meter_attribute[:accounting_tariff_generic][0][:source]).to eq(:manually_entered)
      expect(meter_attribute[:accounting_tariff_generic][0][:type]).to eq(:flat)
    end

    context '#complete' do
      context 'with prices and charges' do
        it "should include tariff" do
          expect(EnergyTariff.complete).to include(energy_tariff)
        end
      end
      context 'without prices or charges' do
        let(:energy_tariff_prices)  { [] }
        let(:energy_tariff_charges)  { [] }
        it "should not include tariff" do
          expect(EnergyTariff.complete).not_to include(energy_tariff)
        end
      end
      context 'without prices' do
        let(:energy_tariff_prices)  { [] }
        it "should include tariff" do
          expect(EnergyTariff.complete).to include(energy_tariff)
        end
      end
      context 'without charges' do
        let(:energy_tariff_charges)  { [] }
        it "should include tariff" do
          expect(EnergyTariff.complete).to include(energy_tariff)
        end
      end
    end
  end

  context 'with differential electricity tariff' do
    let(:energy_tariff)  do
      EnergyTariff.create(
        tariff_holder: school,
        start_date: '2021-04-01',
        end_date: '2022-03-31',
        name: 'My First Tariff',
        meter_type: :electricity,
        tariff_type: :flat_rate,
        vat_rate: 0.05,
        energy_tariff_prices: energy_tariff_prices,
        energy_tariff_charges: energy_tariff_charges,
        )
    end

    let(:attributes) { energy_tariff.to_hash }

    let(:energy_tariff_price_1)  { EnergyTariffPrice.new(start_time: '00:00', end_time: '03:30', value: 1.23, units: 'kwh') }
    let(:energy_tariff_price_2)  { EnergyTariffPrice.new(start_time: '04:00', end_time: '23:30', value: 2.46, units: 'kwh') }
    let(:energy_tariff_charge_1)  { EnergyTariffCharge.new(charge_type: :fixed_charge, value: 4.56, units: :month) }
    let(:energy_tariff_charge_2)  { EnergyTariffCharge.new(charge_type: :agreed_availability_charge, value: 6.78, units: :kva) }

    let(:energy_tariff_prices)  { [energy_tariff_price_1, energy_tariff_price_2] }
    let(:energy_tariff_charges) { [energy_tariff_charge_1, energy_tariff_charge_2] }
    let(:asc_limit_kw_charge) { EnergyTariffCharge.create(charge_type: :asc_limit_kw, value: 5.43) }

    it "should include basic fields" do
      expect(attributes[:name]).to eq('My First Tariff')
      expect(attributes[:start_date]).to eq('01/04/2021')
      expect(attributes[:end_date]).to eq('31/03/2022')
      expect(attributes[:source]).to eq(:manual)
      expect(attributes[:type]).to eq(:differential)
      expect(attributes[:sub_type]).to eq('')
      expect(attributes[:vat]).to eq('5%')
    end

    it "should include duos" do
      energyr_tariff.energy_tariff_charges << EnergyTariffCharge.create(charge_type: :duos_red, value: 6.78)

      expect(attributes[:rates][:duos_red]).to eq('6.78')
    end

    context "with asc limit kw" do
      context "agreed_availability_charge and excess_availability_charge not present" do
        let(:energy_tariff_charges) { [asc_limit_kw_charge] }
        it "should not be included" do
          expect(attributes).to_not have_key(:asc_limit_kw)
        end
      end

      context "and agreed_availability_charge is present" do
        let(:agreed_availability_charge)  { EnergyTariffCharge.create(charge_type: :agreed_availability_charge, value: 6.78, units: :kva) }
        let(:energy_tariff_charges) { [asc_limit_kw_charge, agreed_availability_charge] }
        it "should be included" do
          expect(attributes[:asc_limit_kw]).to eq('5.43')
        end
        it 'should include the charge' do
          expect(attributes[:rates]).to have_key(:agreed_availability_charge)
        end
      end

      context "and excess_availability_charge is present" do
        let(:excess_availability_charge)  { EnergyTariffCharge.create(charge_type: :excess_availability_charge, value: 6.78, units: :kva) }
        let(:energy_tariff_charges) { [asc_limit_kw_charge, excess_availability_charge] }
        it "should be included" do
          expect(attributes[:asc_limit_kw]).to eq('5.43')
        end
        it 'should include the charge' do
          expect(attributes[:rates]).to have_key(:excess_availability_charge)
        end
      end

      context 'only agreed availability charge is present' do
        let(:agreed_availability_charge)  { EnergyTariffCharge.create(charge_type: :agreed_availability_charge, value: 6.78, units: :kva) }
        let(:energy_tariff_charges) { [agreed_availability_charge] }
        it "should not be included" do
          expect(attributes[:rates]).to_not have_key(:asc_limit_kw)
        end
        it 'should not include the charge' do
          expect(attributes[:rates]).to_not have_key(:agreed_availability_charge)
        end
      end

      context 'only excess_availability_charge charge is present' do
        let(:excess_availability_charge)  { EnergyTariffCharge.create(charge_type: :excess_availability_charge, value: 6.78, units: :kva) }
        let(:energy_tariff_charges) { [excess_availability_charge] }
        it "should not be included" do
          expect(attributes).to_not have_key(:asc_limit_kw)
        end
        it 'should not include the charge' do
          expect(attributes[:rates]).to_not have_key(:excess_availability_charge)
        end
      end

      context 'all charges are present' do
        let(:agreed_availability_charge)  { EnergyTariffCharge.create(charge_type: :agreed_availability_charge, value: 6.78, units: :kva) }
        let(:excess_availability_charge)  { EnergyTariffCharge.create(charge_type: :excess_availability_charge, value: 6.78, units: :kva) }
        let(:energy_tariff_charges) { [asc_limit_kw_charge, agreed_availability_charge, excess_availability_charge] }
        it "should be included" do
          expect(attributes).to have_key(:asc_limit_kw)
        end
        it 'should include the charges' do
          expect(attributes[:rates][:agreed_availability_charge]).to eq({:per => 'kva', :rate => '6.78'})
          expect(attributes[:rates][:excess_availability_charge]).to eq({:per => 'kva', :rate => '6.78'})
        end
      end
    end

    it "should include ccl" do
      expect(attributes[:climate_change_levy]).to be_falsey

      energy_tariff.update(ccl: true)
      attributes = energy_tariff.to_hash
      expect(attributes[:climate_change_levy]).to be_truthy
    end

    it "should include tnuos" do
      expect(attributes[:rates][:tnuos]).to be_falsey

      energy_tariff.update(tnuos: true)
      attributes = energy_tariff.to_hash
      expect(attributes[:rates][:tnuos]).to be_truthy
    end

    it "should include standing charges" do
      rates = attributes[:rates]
      expect(rates[:fixed_charge]).to eq({:per => 'month', :rate => '4.56'})
    end

    it "should include rates with adjusted end times" do
      rates = attributes[:rates]
      expect(rates[:rate0][:per]).to eq('kwh')
      expect(rates[:rate0][:rate]).to eq('1.23')
      expect(rates[:rate0][:from]).to eq({hour: "00", minutes: "00"})
      expect(rates[:rate0][:to]).to eq({hour: "03", minutes: "00"})
      expect(rates[:rate1][:per]).to eq('kwh')
      expect(rates[:rate1][:rate]).to eq('2.46')
      expect(rates[:rate1][:from]).to eq({hour: "04", minutes: "00"})
      expect(rates[:rate1][:to]).to eq({hour: "23", minutes: "00"})
    end

    it "should create valid analytics meter attribute" do
      meter_attribute = MeterAttribute.to_analytics([energy_tariff.meter_attribute])

      expect(meter_attribute[:accounting_tariff_generic][0][:name]).to eq('My First Tariff')
      expect(meter_attribute[:accounting_tariff_generic][0][:source]).to eq(:manually_entered)
      expect(meter_attribute[:accounting_tariff_generic][0][:type]).to eq(:differential)
    end

    it "should prevent same start and end time" do
      expect(energy_tariff).to be_valid
      energy_tariff_price_1.update(end_time: energy_tariff_price_1.start_time)
      expect(energy_tariff_price_1).not_to be_valid
      expect(energy_tariff_price_1.errors[:start_time]).to include("can't be the same as end time")
    end

    it "should allow end time of one range to be start time of next" do
      expect(energy_tariff).to be_valid
      energy_tariff_price_1.update(end_time: energy_tariff_price_2.start_time)
      expect(energy_tariff_price_1).to be_valid
      expect(energy_tariff).to be_valid
    end

    it "should prevent overlapping start time" do
      expect(energy_tariff).to be_valid
      energy_tariff_price_2.update(start_time: energy_tariff_price_1.end_time - 1.minute)
      expect(energy_tariff_price_2).not_to be_valid
      expect(energy_tariff_price_2.errors[:start_time]).to include("overlaps with another time range")
    end

    it "should prevent overlapping end time" do
      expect(energy_tariff).to be_valid
      energy_tariff_price_1.update(end_time: energy_tariff_price_2.start_time + 1.minute)
      expect(energy_tariff_price_1).not_to be_valid
      expect(energy_tariff_price_1.errors[:end_time]).to include("overlaps with another time range")
    end

    it "should handle midnight end time as next day" do
      expect(energy_tariff).to be_valid
      energy_tariff_price_2.update(start_time: '07:00', end_time: '00:00')
      energy_tariff_price_1.update(start_time: '08:00', end_time: '09:00')
      expect(energy_tariff_price_1).not_to be_valid
    end
  end
end
