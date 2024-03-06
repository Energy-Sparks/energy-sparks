module Comparisons
  class WeekdayBaseloadVariationController < BaseController
    private

    def key
      :weekday_baseload_variation
    end

    def advice_page_key
      :baseload
    end

    def load_data
      Comparison::WeekdayBaseloadVariation
        .where(school: @schools).where.not(percent_intraday_variation: nil).order(percent_intraday_variation: :desc)
    end

    def create_charts(results)
      create_single_number_chart(results, :percent_intraday_variation, 100.0,
                                 :variation_in_baseload_between_days_of_week, :percent)
    end
  end
end
