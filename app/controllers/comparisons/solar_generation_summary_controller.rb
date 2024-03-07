module Comparisons
  class SolarGenerationSummaryController < BaseController
    private

    def headers
      [
        t('analytics.benchmarking.configuration.column_headings.school'),
        t('analytics.benchmarking.configuration.column_headings.solar_generation'),
        t('analytics.benchmarking.configuration.column_headings.solar_self_consume'),
        t('analytics.benchmarking.configuration.column_headings.solar_export'),
        t('analytics.benchmarking.configuration.column_headings.solar_mains_consume'),
        t('analytics.benchmarking.configuration.column_headings.solar_mains_onsite')
      ]
    end

    def key
      :solar_generation_summary
    end

    def advice_page_key
      :solar_pv
    end

    def load_data
      Comparison::SolarGenerationSummary.where(school: @schools).with_data.sort_default
    end
  end
end
