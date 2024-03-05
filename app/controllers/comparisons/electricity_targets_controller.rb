module Comparisons
  class ElectricityTargetsController < BaseController
    private

    def key
      :electricity_targets
    end

    def advice_page_key
      :electricity_long_term
    end

    def load_data
      Comparison::ElectricityTargets.where(school: @schools).with_data.sort_default
    end

    def create_charts(results)
      create_single_number_chart(results, :current_year_percent_of_target_relative, :percent_above_or_below_target_since_target_set, :percent)
    end
  end
end
