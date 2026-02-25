# frozen_string_literal: true

module Comparisons
  class ChangeInElectricitySinceLastYearController < BaseController
    include ComparisonsHelper

    private

    def header_groups
      Comparison::ChangeInElectricitySinceLastYear.default_header_groups
    end

    def advice_page_key
      :electricity_long_term
    end

    def key
      :change_in_electricity_since_last_year
    end

    def load_data
      Comparison::ChangeInElectricitySinceLastYear.for_schools(@schools).with_data.by_percentage_change(:previous_year_electricity_kwh, :current_year_electricity_kwh)
    end

    # i18n-tasks-use t('analytics.benchmarking.configuration.column_headings.change_in_kwh_pct')
    def create_charts(results)
      calculation = lambda do |result|
        percent_change(result.previous_year_electricity_kwh, result.current_year_electricity_kwh) * 100.0
      end
      [
        Charts::ComparisonChartData.new(results).create_calculated_chart(calculation, 'change_in_kwh_pct', 'percent')
      ]
    end
  end
end
