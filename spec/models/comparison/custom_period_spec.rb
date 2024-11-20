# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Comparison::CustomPeriod do
  context 'with valid attributes' do
    subject(:custom_period) { create(:custom_period) }

    it { expect(custom_period).to be_valid }
    it { expect(custom_period).to validate_presence_of(:current_label) }
    it { expect(custom_period).to validate_presence_of(:current_start_date) }
    it { expect(custom_period).to validate_presence_of(:current_end_date) }
    it { expect(custom_period).to validate_presence_of(:previous_label) }
    it { expect(custom_period).to validate_presence_of(:previous_start_date) }
    it { expect(custom_period).to validate_presence_of(:previous_end_date) }

    it {
      expect(custom_period).to validate_comparison_of(:previous_end_date)
        .is_greater_than_or_equal_to(custom_period.previous_start_date)
        .with_message('must be greater or equal than previous start date')
    }

    it {
      expect(custom_period).to validate_comparison_of(:current_start_date)
        .is_greater_than_or_equal_to(custom_period.previous_end_date)
        .with_message('must be greater or equal to previous end date')
    }

    it {
      expect(custom_period).to validate_comparison_of(:current_end_date)
        .is_greater_than_or_equal_to(custom_period.current_start_date)
        .with_message('must be greater or equal than current start date')
    }
  end
end
