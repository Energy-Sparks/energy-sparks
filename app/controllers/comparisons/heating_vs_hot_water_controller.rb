# frozen_string_literal: true

module Comparisons
  class HeatingVsHotWaterController < BaseController
    private

    def header_groups
      [
        ['', [t('analytics.benchmarking.configuration.column_headings.school')]],
        [
          t('analytics.benchmarking.configuration.column_groups.kwh'),
          [
            t('analytics.benchmarking.configuration.column_headings.gas'),
            t('analytics.benchmarking.configuration.column_headings.hot_water_gas'),
            t('analytics.benchmarking.configuration.column_headings.heating_gas')
          ]
        ],
        ['', [t('analytics.benchmarking.configuration.column_headings.percentage_of_gas_use_for_hot_water')]]
      ]
    end

    def headers
      header_groups.pluck(1).flatten
    end

    def colgroups
      header_groups.map { |group| { label: group[0], colspan: group[1].length } }
    end

    def key
      :heating_vs_hot_water
    end

    def advice_page_key
      :hot_water
    end

    def load_data
      Comparison::HeatingVsHotWater.for_schools(@schools).where.not(last_year_gas_kwh: nil).order(last_year_gas_kwh: :desc)
    end
  end
end
