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
      Comparison::ChangeInEnergySinceLastYear.for_schools(@schools).where_any_present([:current_year_electricity_kwh, :current_year_gas_kwh, :current_year_storage_heaters_kwh, :current_year_solar_pv_kwh])
    end
  end
end
