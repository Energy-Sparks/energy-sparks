require 'rails_helper'

describe EnergyTariffCharge do
  it { is_expected.to validate_presence_of(:charge_type) }
  it { is_expected.to validate_numericality_of(:value).is_greater_than_or_equal_to(0.0) }
end
