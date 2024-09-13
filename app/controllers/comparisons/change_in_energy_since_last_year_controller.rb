module Comparisons
  class ChangeInEnergySinceLastYearController < BaseController
    private

    def colgroups
      [
        { label: '' },
        { label: t('analytics.benchmarking.configuration.column_groups.metering'), colspan: 2 },
        { label: t('analytics.benchmarking.configuration.column_groups.kwh'), colspan: 3 },
        { label: t('analytics.benchmarking.configuration.column_groups.co2_kg'), colspan: 3 },
        { label: t('analytics.benchmarking.configuration.column_groups.cost'), colspan: 3 }
      ]
    end

    def headers
      [
        t('analytics.benchmarking.configuration.column_headings.school'),
        t('analytics.benchmarking.configuration.column_headings.fuel'),
        t('comparisons.column_headings.recent_data'),
        t('analytics.benchmarking.configuration.column_headings.previous_year'),
        t('analytics.benchmarking.configuration.column_headings.last_year'),
        t('analytics.benchmarking.configuration.column_headings.change_pct'),
        t('analytics.benchmarking.configuration.column_headings.previous_year'),
        t('analytics.benchmarking.configuration.column_headings.last_year'),
        t('analytics.benchmarking.configuration.column_headings.change_pct'),
        t('analytics.benchmarking.configuration.column_headings.previous_year'),
        t('analytics.benchmarking.configuration.column_headings.last_year'),
        t('analytics.benchmarking.configuration.column_headings.change_pct')
      ]
    end

    def key
      :change_in_energy_since_last_year
    end

    def load_data
      Comparison::ChangeInEnergySinceLastYear.for_schools(@schools).with_school_configuration.with_consistent_fuels_across_periods.by_total_percentage_change
    end
  end
end
