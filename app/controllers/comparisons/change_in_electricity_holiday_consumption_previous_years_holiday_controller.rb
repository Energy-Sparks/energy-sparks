# frozen_string_literal: true

module Comparisons
  class ChangeInElectricityHolidayConsumptionPreviousYearsHolidayController < BaseController
    private

    def headers
      [t('analytics.benchmarking.configuration.column_headings.school'),
       t('analytics.benchmarking.configuration.column_headings.change_pct'),
       t('analytics.benchmarking.configuration.column_headings.change_£current'),
       t('analytics.benchmarking.configuration.column_headings.change_kwh'),
       t('analytics.benchmarking.configuration.column_headings.most_recent_holiday'),
       t('analytics.benchmarking.configuration.column_headings.previous_holiday')]
    end

    def key
      :change_in_electricity_holiday_consumption_previous_years_holiday
    end

    def load_data
      Comparison::ChangeInElectricityHolidayConsumptionPreviousYearsHoliday
        .where(school: @schools).where.not(difference_percent: nil).order(difference_percent: :desc)
    end

    def create_charts(results)
      create_single_number_chart(results, :difference_percent, 100.0, 'change_pct', 'percent')
    end
  end
end
