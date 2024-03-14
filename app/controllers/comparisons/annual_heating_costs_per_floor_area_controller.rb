module Comparisons
  class AnnualHeatingCostsPerFloorAreaController < BaseController
    private

    def headers
      [
        t('analytics.benchmarking.configuration.column_headings.school'),
        t('analytics.benchmarking.configuration.column_headings.last_year_heating_costs_per_floor_area'),
        t('analytics.benchmarking.configuration.column_headings.last_year_cost_£'),
        t('analytics.benchmarking.configuration.column_headings.saving_if_matched_exemplar_school'),
        t('analytics.benchmarking.configuration.column_headings.last_year_consumption_kwh'),
        t('analytics.benchmarking.configuration.column_headings.last_year_carbon_emissions_tonnes_co2')
      ]
    end

    def key
      :annual_heating_costs_per_floor_area
    end

    def advice_page_key
      :gas_long_term
    end

    def load_data
      Comparison::AnnualHeatingCostsPerFloorArea.for_schools(@schools).with_data.sort_default
    end

    def create_charts(results)
      create_single_number_chart(results, :one_year_gas_per_floor_area_normalised_gbp, nil, :last_year_heating_costs_per_floor_area, :£)
    end
  end
end
