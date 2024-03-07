module Comparisons
  class SolarPvBenefitEstimateController < BaseController
    private

    def headers
      [
        t('analytics.benchmarking.configuration.column_headings.school'),
        t('analytics.benchmarking.configuration.column_headings.size_kwp'),
        t('analytics.benchmarking.configuration.column_headings.payback_years'),
        t('analytics.benchmarking.configuration.column_headings.reduction_in_mains_consumption_pct'),
        t('analytics.benchmarking.configuration.column_headings.saving_optimal_panels')
      ]
    end

    def key
      :solar_pv_benefit_estimate
    end

    def advice_page_key
      :solar_pv
    end

    def load_data
      Comparison::SolarPvBenefitEstimate.where(school: @schools).with_data.sort_default
    end
  end
end
