module Comparisons
  class AnnualEnergyCostsPerFloorAreaController < BaseController
    private

    def headers
      [
        t('analytics.benchmarking.configuration.column_headings.school'),
        t('analytics.benchmarking.configuration.column_headings.type'),
        t('comparisons.column_headings.last_year_electricity_kwh_floor_area'),
        t('comparisons.column_headings.last_year_gas_kwh_floor_area'),
        t('comparisons.column_headings.last_year_storage_heater_kwh_floor_area'),
        t('comparisons.column_headings.last_year_energy_kwh_floor_area'),
        t('analytics.benchmarking.configuration.column_headings.last_year_energy_£_floor_area'),
        t('comparisons.column_headings.last_year_energy_kgco2_floor_area'),
        t('analytics.benchmarking.configuration.column_headings.floor_area')
      ]
    end

    def key
      :annual_energy_costs_per_floor_area
    end

    def load_data
      columns = [:one_year_electricity_per_floor_area_kwh, :one_year_gas_per_floor_area_kwh, :one_year_storage_heater_per_floor_area_kwh]
      Comparison::AnnualEnergyCostsPerUnit.for_schools(@schools).where_any_present(columns).by_total(columns, 'DESC NULLS LAST')
    end

    def create_charts(results)
      create_multi_chart(results, {
        one_year_electricity_per_floor_area_kwh: :last_year_electricity_kwh_floor_area,
        one_year_gas_per_floor_area_kwh: :last_year_gas_kwh_floor_area,
        one_year_storage_heater_per_floor_area_kwh: :last_year_storage_heater_kwh_floor_area
        }, nil, :kwh,
        column_heading_keys: 'comparisons.column_headings')
    end
  end
end
