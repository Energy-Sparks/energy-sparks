module Comparisons
  class AnnualEnergyCostsController < BaseController
    private

    def headers
      [
        t('analytics.benchmarking.configuration.column_headings.school'),
        t('analytics.benchmarking.configuration.column_headings.last_year_electricity_£'),
        t('analytics.benchmarking.configuration.column_headings.last_year_gas_£'),
        t('analytics.benchmarking.configuration.column_headings.last_year_storage_heater_£'),
        t('analytics.benchmarking.configuration.column_headings.total_energy_costs_£'),
        t('analytics.benchmarking.configuration.column_headings.last_year_energy_£_pupil'),
        t('analytics.benchmarking.configuration.column_headings.last_year_energy_co2tonnes'),
        t('analytics.benchmarking.configuration.column_headings.last_year_energy_kwh'),
        t('analytics.benchmarking.configuration.column_headings.type'),
        t('analytics.benchmarking.configuration.column_headings.pupils'),
        t('analytics.benchmarking.configuration.column_headings.floor_area')
      ]
    end

    def key
      :annual_energy_costs
    end

    def load_data
      Comparison::AnnualEnergyCosts.for_schools(@schools).sort_default
    end

    def create_charts(results)
      create_multi_chart(results, {
        last_year_electricity: :last_year_electricity_£,
        last_year_gas: :last_year_gas_£,
        last_year_storage_heaters: :last_year_storage_heater_£,
        }, nil, :£)
    end
  end
end
