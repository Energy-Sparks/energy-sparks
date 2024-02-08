require 'rails_helper'

RSpec.describe Comparison::MetricType, type: :model do
  context 'with valid attributes' do
    subject(:metric_type) { create :metric_type }

    it { expect(metric_type).to be_valid }
    it { expect(metric_type).to validate_uniqueness_of(:key) }
    it { expect(metric_type).to validate_presence_of(:key) }
    it { expect(metric_type).to validate_presence_of(:label) }
    it { expect(metric_type).to validate_presence_of(:units) }
    it { expect(metric_type).to validate_presence_of(:fuel_type) }
    it { expect(metric_type).not_to validate_presence_of(:description) }
  end
end
