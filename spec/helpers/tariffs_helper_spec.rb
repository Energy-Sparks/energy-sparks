require "rails_helper"

describe TariffsHelper do

  let(:user_tariff) { UserTariff.new(name: 'My Tariff', fuel_type: :gas, start_date: '2018-01-01', end_date: '2018-12-31')}

  describe '.user_tariff_title' do
    it "includes name, and dates" do
      expect(user_tariff_title(user_tariff)).to match("My Tariff")
      expect(user_tariff_title(user_tariff)).to match("01/01/2018")
      expect(user_tariff_title(user_tariff)).to match("31/12/2018")
    end
    it "includes mpan for electricity meter" do
      user_tariff.update(fuel_type: :electricity)
      user_tariff.meters << create(:electricity_meter, mpan_mprn: '111122222333344')
      expect(user_tariff_title(user_tariff, true)).to match("MPAN 111122222333344")
      expect(user_tariff_title(user_tariff, false)).not_to match("MPAN 111122222333344")
    end
    it "includes mprns for gas meters" do
      user_tariff.meters << create(:gas_meter, mpan_mprn: '1234567')
      user_tariff.meters << create(:gas_meter, mpan_mprn: '9876543')
      user_tariff.meters << create(:gas_meter, mpan_mprn: '1122334')
      expect(user_tariff_title(user_tariff, true)).to match("MPRN 1234567, 9876543, and 1122334")
      expect(user_tariff_title(user_tariff, false)).not_to match("MPRN 1234567, 9876543, and 1122334")
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

  describe '.user_tariff_charge_value' do
    it "returns string with currency per unit" do
      user_tariff_charge = UserTariffCharge.new(value: 1.23, units: :kva)
      expect(user_tariff_charge_value(user_tariff_charge)).to eq('£1.23 per kVA')
    end
    it "returns simple value" do
      user_tariff_charge = UserTariffCharge.new(value: 1.23)
      expect(user_tariff_charge_value(user_tariff_charge)).to eq('1.23')
    end
  end
end
