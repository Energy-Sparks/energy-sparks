require 'rails_helper'

RSpec.describe Comparison::Period, type: :model do
  context 'with valid attributes' do
    subject(:period) { create :period }

    it { expect(period).to be_valid }
    it { expect(period).to validate_presence_of(:label) }
    it { expect(period).to validate_presence_of(:start_date) }
    it { expect(period).to validate_presence_of(:end_date) }
  end
end
