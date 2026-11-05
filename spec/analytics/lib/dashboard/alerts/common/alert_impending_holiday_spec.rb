# frozen_string_literal: true

require 'rails_helper'
require_relative '../non_estimated_readings_shared'
require_relative '../alert_template_variables_shared'

describe AlertImpendingHoliday do
  subject(:alert) { described_class.new(meter_collection) }

  include_context 'with short-term alert readings'

  [:electricity, :gas, nil].permutation(2) do |fuel_type, other_fuel_type|
    next if fuel_type.nil?

    context "when checking #{fuel_type} in a #{other_fuel_type ? 'dual' : 'single'}-fuel school" do
      let(:fuel_type) { fuel_type }

      if other_fuel_type
        before do
          amr_data = build(:amr_data, :with_date_range, type: other_fuel_type, start_date: amr_end_date - 364.days,
                                                        end_date: amr_end_date)
          other_meter = build(:meter, type: other_fuel_type, amr_data:, meter_collection:)
          meter_collection.set_aggregate_meter(other_fuel_type, other_meter)
        end
      end

      it_behaves_like 'an alert requiring a minimum number of non-estimated readings',
                      minimum_days: 364,
                      extra_cases: { 2 => :not_enough, 3 => :minimum_might_not_be_accurate,
                                     363 => :minimum_might_not_be_accurate }

      it_behaves_like 'an alert without a freshness limit'
    end
  end

  it_behaves_like 'an alert with template variable readers',
                  calculated_variables: {
                    holiday_short_name: nil,
                    holiday_long_name: nil,
                    holiday_start_date_doy: nil,
                    meter_fuel_type_availability: 'electricity only',
                    name_of_last_year_holiday: ''
                  }
end
