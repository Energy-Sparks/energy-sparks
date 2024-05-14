module Comparisons
  class WeekdayBaseloadVariationController < BaseController
    private

    def headers
      [t('analytics.benchmarking.configuration.column_headings.school'),
       t('analytics.benchmarking.configuration.column_headings.variation_in_baseload_between_days_of_week'),
       t('analytics.benchmarking.configuration.column_headings.min_average_weekday_baseload_kw'),
       t('analytics.benchmarking.configuration.column_headings.max_average_weekday_baseload_kw'),
       t('analytics.benchmarking.configuration.column_headings.day_of_week_with_minimum_baseload'),
       t('analytics.benchmarking.configuration.column_headings.day_of_week_with_maximum_baseload'),
       t('analytics.benchmarking.configuration.column_headings.potential_saving')]
    end

    def key
      :weekday_baseload_variation
    end

    def advice_page_key
      :baseload
    end

    def load_data
      Comparison::WeekdayBaseloadVariation
        .for_schools(@schools).where.not(percent_intraday_variation: nil).order(percent_intraday_variation: :desc)
    end

    def create_charts(results)
      create_single_number_chart(results, :percent_intraday_variation, 100.0,
                                 :variation_in_baseload_between_days_of_week, :percent)
    end
  end
end
