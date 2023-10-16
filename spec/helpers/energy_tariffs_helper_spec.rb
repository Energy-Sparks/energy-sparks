require "rails_helper"

describe EnergyTariffsHelper do
  let(:energy_tariff) { EnergyTariff.create(name: 'My Tariff', meter_type: :gas, start_date: '2018-01-01', end_date: '2018-12-31', tariff_holder_type: "School", school: create(:school), tariff_type: 'differential')}

  describe '.energy_tariff_prices_text' do
    it "gives text if default prices exist" do
      EnergyTariffDefaultPricesCreator.new(energy_tariff).process
      expect(energy_tariff_prices_text(energy_tariff)).to include("we've set some default day/night periods")
    end

    it "no text if no default prices exist" do
      energy_tariff.energy_tariff_prices << EnergyTariffPrice.new(start_time: '00:00', end_time: '12:00')
      expect(energy_tariff_prices_text(energy_tariff)).to be_nil
    end
  end

  describe '.energy_tariff_charge_for_type' do
    let(:energy_tariff_charge_1) { EnergyTariffCharge.new(charge_type: :fixed_charge) }
    let(:energy_tariff_charge_2) { EnergyTariffCharge.new(charge_type: :other) }
    let(:energy_tariff_charge_3) { EnergyTariffCharge.new(charge_type: :agreed_capacity) }
    let(:energy_tariff_charges) { [energy_tariff_charge_1, energy_tariff_charge_2, energy_tariff_charge_3] }

    it "finds expected charge for sym" do
      expect(energy_tariff_charge_for_type(energy_tariff_charges, :other)).to eq(energy_tariff_charge_2)
    end

    it "finds expected charge for string" do
      expect(energy_tariff_charge_for_type(energy_tariff_charges, 'other')).to eq(energy_tariff_charge_2)
    end

    it "creates new charge if not found" do
      expect(energy_tariff_charge_for_type(energy_tariff_charges, :site_fee).charge_type).to eq("site_fee")
    end
  end

  describe '.energy_tariff_charge_type_units_for' do
    it "finds expected charge types with capitalized version" do
      expect(energy_tariff_charge_type_units_for(:other)).to eq([['kWh', :kwh], ['day', :day], ['month', :month], ['quarter', :quarter]])
    end

    it "handles missing charge types" do
      expect(energy_tariff_charge_type_units_for(:not_there)).to eq([])
    end
  end

  describe '.energy_tariff_charge_type_units_humanized' do
    it "returns readable units" do
      expect(energy_tariff_charge_type_units_humanized(:kva)).to eq('kVA')
    end
  end

  describe '.energy_tariff_charge_type_description' do
    it "returns name from hash" do
      expect(energy_tariff_charge_type_description(:duos_red)).to eq('Unit rate charge (red)')
    end

    it "returns humanized name" do
      expect(energy_tariff_charge_type_description(:my_new_type)).to eq('My new type')
    end
  end

  describe '.energy_tariff_charge_type_value_label' do
    it "returns label from hash" do
      expect(energy_tariff_charge_type_value_label(:duos_red)).to eq('Rate')
    end

    it "returns default label" do
      expect(energy_tariff_charge_type_value_label(:my_new_type)).to eq('Value in £')
    end
  end

  describe '.energy_tariff_charge_value' do
    it "returns string with currency per unit" do
      energy_tariff_charge = EnergyTariffCharge.new(value: 1.23, units: :kva)
      expect(energy_tariff_charge_value(energy_tariff_charge)).to eq('£1.23 per kVA')
    end

    it "returns simple value" do
      energy_tariff_charge = EnergyTariffCharge.new(value: 1.23)
      expect(energy_tariff_charge_value(energy_tariff_charge)).to eq('1.23')
    end
  end

  describe '.convert_value_to_long_currency' do
    it 'returns a value formatted as a long currency string with zeros to at least 2 decimal places' do
      expect(convert_value_to_long_currency(0.3)).to eq('£0.30')
      expect(convert_value_to_long_currency(0.311)).to eq('£0.311')
      expect(convert_value_to_long_currency(0.30000100000000)).to eq('£0.300001')
      expect(convert_value_to_long_currency(1)).to eq('£1.00')
      expect(convert_value_to_long_currency(1.5)).to eq('£1.50')
      expect(convert_value_to_long_currency(1.511111)).to eq('£1.511111')
      expect(convert_value_to_long_currency(1.50000000000000)).to eq('£1.50')
      expect(convert_value_to_long_currency(100000005.50000000000000)).to eq('£100000005.50')
      expect(convert_value_to_long_currency(0.3, currency: '$')).to eq('$0.30')
    end
  end
end
