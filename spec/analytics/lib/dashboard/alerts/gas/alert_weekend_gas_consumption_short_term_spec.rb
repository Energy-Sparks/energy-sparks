# frozen_string_literal: true

require 'rails_helper'
require_relative '../non_estimated_readings_shared'
require_relative '../alert_template_variables_shared'

RSpec.describe AlertWeekendGasConsumptionShortTerm do
  subject(:alert) { described_class.new(meter_collection) }

  context 'when a school has gas' do
    include_context 'with short-term alert readings'

    let(:fuel_type) { :gas }

    it_behaves_like 'an alert requiring a minimum number of non-estimated readings', minimum_days: 7
    it_behaves_like 'an alert requiring recent non-estimated readings', max_days_out_of_date: 21

    it_behaves_like 'an alert with template variable readers',
                    calculated_variables: {
                      last_7_day_intraday_kwh_chart: :alert_weekend_last_week_gas_datetime_kwh,
                      last_7_day_intraday_kw_chart: :alert_weekend_last_week_gas_datetime_kw,
                      last_7_day_intraday_£_chart: :alert_weekend_last_week_gas_datetime_£,
                      last_7_day_intraday_£current_chart: :alert_weekend_last_week_gas_datetime_£current
                    }
  end

  it_behaves_like 'a never relevant alert', :electricity
end
