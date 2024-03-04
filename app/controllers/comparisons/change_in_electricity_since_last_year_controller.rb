module Comparisons
  class ChangeInElectricitySinceLastYearController < BaseController
    private

    def advice_page_key
      :electricity_long_term
    end

    def key
      :change_in_electricity_since_last_year
    end

    def load_data
      Comparison::ChangeInElectricitySinceLastYear.where(school: @schools).with_data.by_percentage_change
    end
  end
end
