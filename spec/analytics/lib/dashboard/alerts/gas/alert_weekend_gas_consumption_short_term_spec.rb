# frozen_string_literal: true

require 'rails_helper'
require_relative '../non_estimated_readings_shared'

RSpec.describe AlertWeekendGasConsumptionShortTerm do
  subject(:alert) { described_class.new(meter_collection) }

  context 'when a school has gas' do
    include_context 'with short-term alert readings'

    let(:fuel_type) { :gas }

    it_behaves_like 'an alert requiring a minimum number of non-estimated readings', minimum_days: 7
    it_behaves_like 'an alert requiring recent non-estimated readings', max_days_out_of_date: 21

    describe 'template variable readers' do
      def chart_methods
        { last_7_day_intraday_kwh_chart: :alert_weekend_last_week_gas_datetime_kwh,
          last_7_day_intraday_kw_chart: :alert_weekend_last_week_gas_datetime_kw,
          last_7_day_intraday_£_chart: :alert_weekend_last_week_gas_datetime_£,
          last_7_day_intraday_£current_chart: :alert_weekend_last_week_gas_datetime_£current }
      end

      it 'reads each non-calculated template variable from its instance variable' do
        names = described_class.const_get(:TEMPLATE_VARIABLES, false).keys - chart_methods.keys
        names.each do |name|
          alert.instance_variable_set("@#{name}", 123)

          expect(alert.public_send(name)).to eq(123)
        end
      end

      it 'preserves the calculated chart methods' do
        chart_methods.each do |name, chart|
          expect(alert.public_send(name)).to eq(chart)
        end
      end
    end
  end

  it_behaves_like 'a never relevant alert', :electricity
end
