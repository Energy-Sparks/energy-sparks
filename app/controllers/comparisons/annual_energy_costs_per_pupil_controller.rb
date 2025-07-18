module Comparisons
  class AnnualEnergyCostsPerPupilController < BaseController
    private

    def headers
      [
        t('analytics.benchmarking.configuration.column_headings.school'),
        t('analytics.benchmarking.configuration.column_headings.type'),
        t('analytics.benchmarking.configuration.column_headings.last_year_electricity_kwh_pupil'),
        t('analytics.benchmarking.configuration.column_headings.last_year_gas_kwh_pupil'),
        t('analytics.benchmarking.configuration.column_headings.last_year_storage_heater_kwh_pupil'),
        t('analytics.benchmarking.configuration.column_headings.last_year_energy_kwh_pupil'),
        t('analytics.benchmarking.configuration.column_headings.last_year_energy_£_pupil'),
        t('analytics.benchmarking.configuration.column_headings.last_year_energy_kgco2_pupil'),
        t('analytics.benchmarking.configuration.column_headings.pupils')
      ]
    end

    def key
      :annual_energy_costs_per_pupil
    end

    def load_data
      columns = [:one_year_electricity_per_pupil_kwh, :one_year_gas_per_pupil_kwh, :one_year_storage_heater_per_pupil_kwh]
      Comparison::AnnualEnergyCostsPerUnit.for_schools(@schools).where_any_present(columns).by_total(columns)
    end

    def create_charts(results)
      create_multi_chart(results, {
        one_year_electricity_per_pupil_kwh: :last_year_electricity_kwh_pupil,
        one_year_gas_per_pupil_kwh: :last_year_gas_kwh_pupil,
        one_year_storage_heater_per_pupil_kwh: :last_year_storage_heater_kwh_pupil
        }, nil, :kwh)
    end
  end
end
