module Comparisons
  class SeasonalBaseloadVariationController < BaseController
    private

    def headers
      [t('analytics.benchmarking.configuration.column_headings.school'),
       t('analytics.benchmarking.configuration.column_headings.percent_increase_on_winter_baseload_over_summer'),
       t('analytics.benchmarking.configuration.column_headings.summer_baseload_kw'),
       t('analytics.benchmarking.configuration.column_headings.winter_baseload_kw'),
       t('analytics.benchmarking.configuration.column_headings.saving_if_same_all_year_around')]
    end

    def key
      :seasonal_baseload_variation
    end

    def advice_page_key
      :baseload
    end

    def load_data
      Comparison::SeasonalBaseloadVariation
        .for_schools(@schools).where.not(percent_seasonal_variation: nil).order(percent_seasonal_variation: :desc)
    end

    def create_charts(results)
      create_single_number_chart(results, :percent_seasonal_variation, 100.0,
                                 :percent_increase_on_winter_baseload_over_summer, :percent)
    end
  end
end
