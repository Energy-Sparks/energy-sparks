# frozen_string_literal: true

module Comparisons
  class AnnualChangeInElectricityOutOfHoursUseController < BaseController
    private

    def colgroups
      [
        { label: '' },
        { label: t('analytics.benchmarking.configuration.column_groups.kwh'), colspan: 3 },
        { label: t('analytics.benchmarking.configuration.column_groups.co2_kg'), colspan: 3 },
        { label: t('analytics.benchmarking.configuration.column_groups.cost'), colspan: 3 }
      ]
    end

    def headers
      [
        t('analytics.benchmarking.configuration.column_headings.school'),
        t('analytics.benchmarking.configuration.column_headings.previous_year_out_of_hours_kwh'),
        t('analytics.benchmarking.configuration.column_headings.last_year_out_of_hours_kwh'),
        t('analytics.benchmarking.configuration.column_headings.change_pct'),
        t('analytics.benchmarking.configuration.column_headings.previous_year_out_of_hours_co2'),
        t('analytics.benchmarking.configuration.column_headings.last_year_out_of_hours_co2'),
        t('analytics.benchmarking.configuration.column_headings.change_pct'),
        t('analytics.benchmarking.configuration.column_headings.previous_year_out_of_hours_cost_ct'),
        t('analytics.benchmarking.configuration.column_headings.last_year_out_of_hours_cost_ct'),
        t('analytics.benchmarking.configuration.column_headings.change_pct')
      ]
    end

    def key
      :annual_change_in_electricity_out_of_hours_use
    end

    def advice_page_key
      :electricity_out_of_hours
    end

    def load_data
      Comparison::AnnualChangeInElectricityOutOfHoursUse.where(school: @schools)
                                                        .where.not(previous_out_of_hours_kwh: nil)
                                                        .order(previous_out_of_hours_kwh: :desc)
    end
  end
end
