require 'rails_helper'

describe EnergyTariffCharge do
  it { should validate_presence_of(:charge_type) }
  it { should validate_numericality_of(:value).is_greater_than_or_equal_to(0.0) }
end
