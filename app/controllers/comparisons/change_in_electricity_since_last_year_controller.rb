# frozen_string_literal: true

module Comparisons
  class ChangeInElectricitySinceLastYearController < BaseController
    private

    def colgroups
      [
        { label: '' },
        { label: t('analytics.benchmarking.configuration.column_groups.kwh'), colspan: 3 },
        { label: t('analytics.benchmarking.configuration.column_groups.co2_kg'), colspan: 3 },
        { label: t('analytics.benchmarking.configuration.column_groups.gbp'), colspan: 3 },
        { label: t('analytics.benchmarking.configuration.column_groups.solar_self_consumption') }
      ]
    end

    def headers
      [
        t('analytics.benchmarking.configuration.column_headings.school'),
        t('analytics.benchmarking.configuration.column_headings.previous_year'),
        t('analytics.benchmarking.configuration.column_headings.last_year'),
        t('analytics.benchmarking.configuration.column_headings.change_pct'),
        t('analytics.benchmarking.configuration.column_headings.previous_year'),
        t('analytics.benchmarking.configuration.column_headings.last_year'),
        t('analytics.benchmarking.configuration.column_headings.change_pct'),
        t('analytics.benchmarking.configuration.column_headings.previous_year'),
        t('analytics.benchmarking.configuration.column_headings.last_year'),
        t('analytics.benchmarking.configuration.column_headings.change_pct'),
        t('analytics.benchmarking.configuration.column_headings.estimated')
      ]
    end

    def advice_page_key
      :electricity_long_term
    end

    def key
      :change_in_electricity_since_last_year
    end

    def load_data
      Comparison::ChangeInElectricitySinceLastYear.where(school: @schools).with_data.by_percentage_change
    end
  end
end
