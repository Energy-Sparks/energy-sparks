require 'rails_helper'

RSpec.describe Comparison::Period, type: :model do
  context 'with valid attributes' do
    subject(:period) { create :period }

    it { expect(period).to be_valid }
    it { expect(period).to validate_presence_of(:current_label) }
    it { expect(period).to validate_presence_of(:current_start_date) }
    it { expect(period).to validate_presence_of(:current_end_date) }
    it { expect(period).to validate_presence_of(:previous_label) }
    it { expect(period).to validate_presence_of(:previous_start_date) }
    it { expect(period).to validate_presence_of(:previous_end_date) }
  end
end
