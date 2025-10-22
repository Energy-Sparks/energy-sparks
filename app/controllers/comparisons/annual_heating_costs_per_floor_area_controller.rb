module Comparisons
  class AnnualHeatingCostsPerFloorAreaController < BaseController
    include MultipleTableComparison

    private

    def storage_heaters
      @storage_heaters = @results.any? { |r| r.storage_heaters_last_year_kwh != nil }
    end

    def table_configuration
      configuration = {
        gas: I18n.t('comparisons.tables.gas_usage')
      }
      if storage_heaters
        configuration[:storage_heater] = I18n.t('comparisons.tables.storage_heater_usage')
      end
      configuration
    end

    def colgroups
      [
        { label: '' },
        { label: t('analytics.benchmarking.configuration.column_groups.last_year'), colspan: 3 },
        { label: t('analytics.benchmarking.configuration.column_groups.last_year_per_floor_area'), colspan: 3 },
        { label: '' }
      ]
    end

    def headers
      [
        t('analytics.benchmarking.configuration.column_headings.school'),
        t('kwh'),
        t('£'),
        t('usage_co2'),
        t('kwh'),
        t('£'),
        t('usage_co2'),
        t('analytics.benchmarking.configuration.column_headings.saving_if_matched_exemplar_school'),
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

    # i18n-tasks-use t('analytics.benchmarking.configuration.column_headings.last_year_gas_kwh_floor_area')
    def create_charts(results)
      create_single_number_chart(results, :one_year_gas_per_floor_area_kwh, nil, :last_year_gas_kwh_floor_area, :kwh)
    end
  end
end
