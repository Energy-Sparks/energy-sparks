module Comparisons
  class ChangeInEnergySinceLastYearController < BaseController
    private

    def colgroups
      [
        { label: '', colspan: 2 },
        { label: t('analytics.benchmarking.configuration.column_groups.kwh'), colspan: 3 },
        { label: t('analytics.benchmarking.configuration.column_groups.co2_kg'), colspan: 3 },
        { label: t('analytics.benchmarking.configuration.column_groups.cost'), colspan: 3 },
        { label: t('analytics.benchmarking.configuration.column_groups.metering') }
      ]
    end

    def headers
      [
        t('analytics.benchmarking.configuration.column_headings.school'),
        t('analytics.benchmarking.configuration.column_headings.fuel'),
        t('analytics.benchmarking.configuration.column_headings.previous_year'),
        t('analytics.benchmarking.configuration.column_headings.last_year'),
        t('analytics.benchmarking.configuration.column_headings.change_pct'),
        t('analytics.benchmarking.configuration.column_headings.previous_year'),
        t('analytics.benchmarking.configuration.column_headings.last_year'),
        t('analytics.benchmarking.configuration.column_headings.change_pct'),
        t('analytics.benchmarking.configuration.column_headings.previous_year'),
        t('analytics.benchmarking.configuration.column_headings.last_year'),
        t('analytics.benchmarking.configuration.column_headings.change_pct'),
        t('analytics.benchmarking.configuration.column_headings.no_recent_data')
      ]
    end

    def key
      :change_in_energy_since_last_year
    end

    def advice_page_key
      :total_energy_use
    end

    def load_data
      Comparison::ChangeInEnergySinceLastYear.for_schools(@schools).with_total_that_covers_both_periods.by_total_percentage_change
    end
  end
end
