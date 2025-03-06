# frozen_string_literal: true

module Comparisons
  class ChangeInElectricitySinceLastYearController < BaseController
    private

    def header_groups
      [
        { label: '',
          headers: [t('analytics.benchmarking.configuration.column_headings.school')] },
        { label: t('analytics.benchmarking.configuration.column_groups.kwh'),
          headers: [
            t('analytics.benchmarking.configuration.column_headings.previous_year'),
            t('analytics.benchmarking.configuration.column_headings.last_year'),
            t('analytics.benchmarking.configuration.column_headings.change_pct')
          ] },
        { label: t('analytics.benchmarking.configuration.column_groups.co2_kg'),
          headers: [
            t('analytics.benchmarking.configuration.column_headings.previous_year'),
            t('analytics.benchmarking.configuration.column_headings.last_year'),
            t('analytics.benchmarking.configuration.column_headings.change_pct')
          ] },
        { label: t('analytics.benchmarking.configuration.column_groups.gbp'),
          headers: [
            t('analytics.benchmarking.configuration.column_headings.previous_year'),
            t('analytics.benchmarking.configuration.column_headings.last_year'),
            t('analytics.benchmarking.configuration.column_headings.change_pct')
          ] },
        { label: t('analytics.benchmarking.configuration.column_groups.solar_self_consumption'),
          headers: [t('analytics.benchmarking.configuration.column_headings.estimated')] }
      ]
    end

    def advice_page_key
      :electricity_long_term
    end

    def key
      :change_in_electricity_since_last_year
    end

    def load_data
      Comparison::ChangeInElectricitySinceLastYear.for_schools(@schools).with_data.by_percentage_change(:previous_year_electricity_kwh, :current_year_electricity_kwh)
    end
  end
end
