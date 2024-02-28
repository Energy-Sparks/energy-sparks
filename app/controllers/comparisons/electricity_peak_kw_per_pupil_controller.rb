# frozen_string_literal: true

module Comparisons
  class ElectricityPeakKwPerPupilController < BaseController
    private

    def title_key
      'analytics.benchmarking.chart_table_config.electricity_peak_kw_per_pupil'
    end

    def advice_page_key
      :electricity_intraday
    end

    def load_data
      Comparison::ElectricityPeakKwPerPupil.where(school: @schools)
                                           .order(average_school_day_last_year_kw_per_floor_area: :desc)
    end

    def create_charts(results)
      create_single_number_chart(results, :average_school_day_last_year_kw_per_floor_area, 1000.0, 'w_floor_area', 'w')
    end
  end
end
