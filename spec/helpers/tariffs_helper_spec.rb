require "rails_helper"

describe TariffsHelper do

  let(:user_tariff) { UserTariff.new(name: 'My Tariff', fuel_type: :gas, start_date: '2018-01-01', end_date: '2018-12-31')}

  describe '.user_tariff_title' do
    it "includes name, fuel type and dates" do
      expect(user_tariff_title(user_tariff)).to match("My Tariff")
      expect(user_tariff_title(user_tariff)).to match("gas")
      expect(user_tariff_title(user_tariff)).to match("01/01/2018")
    end
  end

  describe '.user_tariff_charge_for_type' do

    let(:user_tariff_charge_1) { UserTariffCharge.new(charge_type: :fixed_charge) }
    let(:user_tariff_charge_2) { UserTariffCharge.new(charge_type: :other) }
    let(:user_tariff_charge_3) { UserTariffCharge.new(charge_type: :agreed_capacity) }
    let(:user_tariff_charges) { [user_tariff_charge_1, user_tariff_charge_2, user_tariff_charge_3] }

    it "finds expected charge for sym" do
      expect(user_tariff_charge_for_type(user_tariff_charges, :other)).to eq(user_tariff_charge_2)
    end
    it "finds expected charge for string" do
      expect(user_tariff_charge_for_type(user_tariff_charges, 'other')).to eq(user_tariff_charge_2)
    end
    it "creates new charge if not found" do
      expect(user_tariff_charge_for_type(user_tariff_charges, :site_fee).charge_type).to eq("site_fee")
    end
  end

  describe '.user_tariff_charge_type_units_for' do
    it "finds expected charge types with capitalized version" do
      expect(user_tariff_charge_type_units_for(:other)).to eq([['kWh', :kwh], ['day', :day], ['month', :month], ['quarter', :quarter]])
    end
    it "handles missing charge types" do
      expect(user_tariff_charge_type_units_for(:not_there)).to eq([])
    end
  end

  describe '.user_tariff_charge_type_units_humanized' do
    it "returns readable units" do
      expect(user_tariff_charge_type_units_humanized(:kva)).to eq('kVA')
    end
  end

  describe '.user_tariff_charge_type_description' do
    it "returns name from hash" do
      expect(user_tariff_charge_type_description(:duos_red)).to eq('Unit rate charge (red)')
    end
    it "returns humanized name" do
      expect(user_tariff_charge_type_description(:my_new_type)).to eq('My new type')
    end
  end

  describe '.user_tariff_charge_type_value_label' do
    it "returns label from hash" do
      expect(user_tariff_charge_type_value_label(:duos_red)).to eq('Rate')
    end
    it "returns default label" do
      expect(user_tariff_charge_type_value_label(:my_new_type)).to eq('Value in £')
    end
  end
end
