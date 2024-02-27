# frozen_string_literal: true

module Comparisons
  class ChangeInElectricitySinceLastYearController < BaseController
    private

    def advice_page_key
      :electricity_long_term
    end

    def title_key
      'analytics.benchmarking.chart_table_config.change_in_electricity_since_last_year'
    end

    def load_data
      # TODO
      Comparison::ChangeInElectricitySinceLastYear.where(school: @schools).where.not(previous_year_electricity_kwh: nil, current_year_electricity_kwh: nil).order(current_year_electricity_kwh: :desc)
    end
  end
end
