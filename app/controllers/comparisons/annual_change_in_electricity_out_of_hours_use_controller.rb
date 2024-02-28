# frozen_string_literal: true

module Comparisons
  class AnnualChangeInElectricityOutOfHoursUseController < BaseController
    private

    def title_key
      'analytics.benchmarking.chart_table_config.annual_change_in_electricity_out_of_hours_use'
    end

    def advice_page_key
      :electricity_out_of_hours
    end

    def load_data
      Comparison::AnnualChangeInElectricityOutOfHoursUse.where(school: @schools)
                                                        .where.not(previous_out_of_hours_kwh: nil)
                                                        .order(previous_out_of_hours_kwh: :desc)
    end
  end
end
