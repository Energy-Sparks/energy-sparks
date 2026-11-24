# frozen_string_literal: true

require 'rails_helper'
require_relative '../non_estimated_readings_shared'
require_relative '../alert_template_variables_shared'

describe AlertElectricityPeakKWVersusBenchmark do
  subject(:alert) { described_class.new(meter_collection) }

  include_context 'with short-term alert readings'

  it_behaves_like 'an alert requiring a minimum number of non-estimated readings', minimum_days: 60

  describe '#meter_readings_up_to_date_enough?' do
    it 'preserves the absence of a freshness limit' do
      travel_to amr_end_date + 1.year

      expect(alert.meter_readings_up_to_date_enough?).to be true
    end
  end

  it_behaves_like 'an alert with template variable readers',
                  calculated_variables: {
                    electricity_intraday_comparison_chart_6_months_apart: :intraday_line_school_days_6months
                  }

  it_behaves_like 'a never relevant alert', :gas
end
