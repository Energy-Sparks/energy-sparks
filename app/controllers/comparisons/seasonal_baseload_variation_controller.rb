module Comparisons
  class SeasonalBaseloadVariationController < BaseController
    private

    def key
      :seasonal_baseload_variation
    end

    def advice_page_key
      :baseload
    end

    def load_data
      Comparison::SeasonalBaseloadVariation
        .where(school: @schools).where.not(percent_seasonal_variation: nil).order(percent_seasonal_variation: :desc)
    end

    def create_charts(results)
      create_single_number_chart(results, :percent_seasonal_variation, 100.0,
                                 :percent_increase_on_winter_baseload_over_summer, :percent)
    end
  end
end
