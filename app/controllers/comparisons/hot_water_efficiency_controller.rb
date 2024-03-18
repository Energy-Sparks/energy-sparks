module Comparisons
  class HotWaterEfficiencyController < BaseController
    private

    def headers
      [
        t('analytics.benchmarking.configuration.column_headings.school'),
        t('analytics.benchmarking.configuration.column_headings.cost_per_pupil'),
        t('analytics.benchmarking.configuration.column_headings.efficiency_of_system'),
        t('analytics.benchmarking.configuration.column_headings.saving_improving_timing'),
        t('analytics.benchmarking.configuration.column_headings.saving_with_pou_electric_hot_water')
      ]
    end

    def key
      :hot_water_efficiency
    end

    def advice_page_key
      :hot_water
    end

    def load_data
      Comparison::HotWaterEfficiency.for_schools(@schools).with_data.sort_default
    end

    def create_charts(results)
      create_single_number_chart(results, :avg_gas_per_pupil_gbp, nil, :cost_per_pupil, :£)
    end
  end
end
