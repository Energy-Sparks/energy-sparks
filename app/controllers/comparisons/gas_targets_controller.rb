module Comparisons
  class GasTargetsController < BaseController
    private

    def headers
      [
        t('analytics.benchmarking.configuration.column_headings.school'),
        t('analytics.benchmarking.configuration.column_headings.percent_above_or_below_target_since_target_set'),
        t('analytics.benchmarking.configuration.column_headings.percent_above_or_below_last_year'),
        t('analytics.benchmarking.configuration.column_headings.kwh_consumption_since_target_set'),
        t('analytics.benchmarking.configuration.column_headings.target_kwh_consumption'),
        t('analytics.benchmarking.configuration.column_headings.last_year_kwh_consumption'),
        t('analytics.benchmarking.configuration.column_headings.start_date_for_target')
      ]
    end

    def key
      :gas_targets
    end

    def advice_page_key
      :gas_long_term
    end

    def load_data
      Comparison::GasTargets.for_schools(@schools).with_data.sort_default
    end

    def create_charts(results)
      create_single_number_chart(results, :current_year_percent_of_target_relative, 100.0, :percent_above_or_below_target_since_target_set, :percent)
    end
  end
end
