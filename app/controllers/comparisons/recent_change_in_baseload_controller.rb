module Comparisons
  class RecentChangeInBaseloadController < BaseController
    private

    def headers
      [
        t('analytics.benchmarking.configuration.column_headings.school'),
        t('analytics.benchmarking.configuration.column_headings.change_in_baseload_last_week_v_year_pct'),
        t('analytics.benchmarking.configuration.column_headings.average_baseload_last_year_kw'),
        t('analytics.benchmarking.configuration.column_headings.average_baseload_last_week_kw'),
        t('analytics.benchmarking.configuration.column_headings.change_in_baseload_last_week_v_year_kw'),
        t('analytics.benchmarking.configuration.column_headings.cost_of_change_in_baseload'),
      ]
    end

    def key
      :recent_change_in_baseload
    end

    def advice_page_key
      :baseload
    end

    def load_data
      Comparison::RecentChangeInBaseload.with_data.sort_default
    end

    def create_charts(results)
      create_single_number_chart(results, :predicted_percent_increase_in_usage, nil, :change_in_baseload_last_week_v_year_pct, :percent)
    end
  end
end
