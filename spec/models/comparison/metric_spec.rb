require 'rails_helper'

RSpec.describe Comparison::Metric, type: :model do
  context 'with valid attributes' do
    subject(:metric) { create :metric }

    it { expect(metric).to be_valid }
    it { expect(metric).to validate_presence_of(:value) }
  end
end
