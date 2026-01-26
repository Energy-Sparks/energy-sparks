# frozen_string_literal: true

require 'rails_helper'

describe Targets::MonthlyConsumptionService do
  describe '.any_missing?' do
    context 'with a complete target' do
      let(:target) { create(:school_target, :with_monthly_consumption, gas: nil, storage_heaters: nil) }

      it { expect(described_class.any_missing?(target)).to be false }
    end

    context 'with a no consumption' do
      let(:target) { create(:school_target) }

      it { expect(described_class.any_missing?(target)).to be true }
    end

    context 'with missing previous consumption' do
      let(:target) { create(:school_target, :with_monthly_consumption, previous_consumption: [*[1] * 11, nil]) }

      it { expect(described_class.any_missing?(target)).to be true }
    end
  end
end
