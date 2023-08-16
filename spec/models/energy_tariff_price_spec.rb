require 'rails_helper'

describe EnergyTariffPrice do
  it { should validate_presence_of(:start_time) }
  it { should validate_presence_of(:end_time) }
  it { should validate_presence_of(:value) }
  it { should validate_presence_of(:units) }
  it { should validate_numericality_of(:value).is_greater_than_or_equal_to(1.0) }
end
