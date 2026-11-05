# frozen_string_literal: true

require 'rails_helper'
require_relative '../alert_template_variables_shared'

RSpec.describe AlertPeriodComparisonBase do
  subject(:alert) { described_class.allocate }

  it_behaves_like 'an alert with template variable readers',
                  calculated_variables: {
                    'prefix_1' => I18nHelper.adjective(:up),
                    'prefix_2' => I18nHelper.adjective(:increase)
                  },
                  additional_readers: %i[current_holiday_temperatures current_holiday_average_temperature
                                         previous_holiday_temperatures previous_holiday_average_temperature
                                         current_period_kwhs previous_period_kwhs_unadjusted
                                         previous_period_average_kwh_unadjusted] do
    let(:template_variable_names) do
      described_class.dynamic_template_variables(:electricity).keys.reject do |name|
        alert.method(name).owner == described_class
      end
    end

    before { alert.instance_variable_set(:@difference_percent, 0.1) }
  end

  it 'keeps template metadata fuel-specific' do
    expect(described_class.dynamic_template_variables(:electricity)[:current_period_kwh][:units])
      .to eq(kwh: :electricity)
    expect(described_class.dynamic_template_variables(:gas)[:current_period_kwh][:units]).to eq(kwh: :gas)
  end
end
