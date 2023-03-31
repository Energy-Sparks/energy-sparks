
require 'rails_helper'

describe UserTariffChargeValidator do

  let(:user_tariff) { create(:user_tariff, flat_rate: false) }
  let(:agreed_availability_charge) { build(:user_tariff_charge, charge_type: :agreed_availability_charge, user_tariff: user_tariff, value: 12) }
  let(:excess_availability_charge) { build(:user_tariff_charge, charge_type: :excess_availability_charge, user_tariff: user_tariff, value: 45) }
  let(:asc_limit_kw) { build(:user_tariff_charge, charge_type: :asc_limit_kw, user_tariff: user_tariff, value: 67) }
  let(:other_charge) { build(:user_tariff_charge, charge_type: :other, user_tariff: user_tariff, value: 89) }

  it 'checks valid with no charges' do
    validator = UserTariffChargeValidator.new([])
    expect(validator.valid?).to be true
    expect(validator.message).to be nil
  end

  it 'checks invalid if agreed_availability_charge' do
    validator = UserTariffChargeValidator.new([agreed_availability_charge])
    expect(validator.valid?).to be false
    expect(validator.message).to eq('Available capacity must be set if Agreed Availability of Excess Availability are set')
  end

  it 'checks invalid if excess_availability_charge' do
    validator = UserTariffChargeValidator.new([excess_availability_charge])
    expect(validator.valid?).to be false
    expect(validator.message).to eq('Available capacity must be set if Agreed Availability of Excess Availability are set')
  end

  it 'checks valid if other charge' do
    validator = UserTariffChargeValidator.new([other_charge])
    expect(validator.valid?).to be true
    expect(validator.message).to be nil
  end
end
