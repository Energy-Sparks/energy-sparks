module Comparisons
  class HolidayUsageLastYearController < BaseController
    private

    def headers
      [
        t('analytics.benchmarking.configuration.column_headings.school'),
        t('analytics.benchmarking.configuration.column_headings.gas_cost_ht'),
        t('analytics.benchmarking.configuration.column_headings.electricity_cost_ht'),
        t('analytics.benchmarking.configuration.column_headings.gas_cost_ct'),
        t('analytics.benchmarking.configuration.column_headings.electricity_cost_ct'),
        t('analytics.benchmarking.configuration.column_headings.gas_kwh_per_floor_area'),
        t('analytics.benchmarking.configuration.column_headings.electricity_kwh_per_pupil'),
        t('analytics.benchmarking.configuration.column_headings.holiday')
      ]
    end

    def key
      :holiday_usage_last_year
    end

    def load_data
      Comparison::HolidayUsageLastYear.for_schools(@schools).with_data.sort_default
    end

    def create_charts(results)
      create_multi_chart(results, {
        last_year_holiday_gas_gbp: :gas_cost_ht,
        last_year_holiday_electricity_gbp: :electricity_cost_ht,
        last_year_holiday_gas_gbpcurrent: :gas_cost_ct,
        last_year_holiday_electricity_gbpcurrent: :electricity_cost_ct,
        }, nil, :£)
    end
  end
end
