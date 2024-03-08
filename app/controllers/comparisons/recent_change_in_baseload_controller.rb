module Comparisons
  class RecentChangeInBaseloadController < BaseController
    private

    def key
      :recent_change_in_baseload
    end

    def advice_page_key
      :your_advice_page_key
    end

    def load_data
      # change as needed
      Comparison::RecentChangeInBaseload.where(school: @schools).where.not(variable_name: nil).order(variable_name: :desc)
    end

    def create_charts(results)
      # change as appropriate!
      create_single_number_chart(results, :current_year_percent_of_target_relative, :percent_above_or_below_target_since_target_set, :percent)
    end
  end
end
