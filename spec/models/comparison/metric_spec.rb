require 'rails_helper'

RSpec.describe Comparison::Metric, type: :model do
  describe 'validations' do
    context 'with valid attributes' do
      subject(:metric) { create :metric }

      it { expect(metric).to be_valid }
      it { expect(metric).to validate_presence_of(:school) }
      it { expect(metric).to validate_presence_of(:alert_type) }
      it { expect(metric).to validate_presence_of(:metric_type) }
      it { expect(metric).to validate_presence_of(:value) }
    end

    it_behaves_like 'an enum reporting period', model: :metric
  end
end
