# frozen_string_literal: true

module Comparisons
  class ChangeInElectricityHolidayConsumptionPreviousHolidayController < BaseController
    private

    def title_key
      'analytics.benchmarking.chart_table_config.change_in_electricity_holiday_consumption_previous_holiday'
    end

    def load_data
      Comparison::ChangeInElectricityHolidayConsumptionPreviousHoliday
        .where(school: @schools).where.not(difference_percent: nil).order(difference_percent: :desc)
    end

    def create_charts(results)
      create_single_number_chart(results, :difference_percent, 100.0, 'change_pct', 'percent')
    end
  end
end
