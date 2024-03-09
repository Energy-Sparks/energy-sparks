# frozen_string_literal: true

module Comparisons
  class ElectricityPeakKwPerPupilController < BaseController
    private

    def headers
      [
        t('analytics.benchmarking.configuration.column_headings.school'),
        t('analytics.benchmarking.configuration.column_headings.w_floor_area'),
        t('analytics.benchmarking.configuration.column_headings.average_peak_kw'),
        t('analytics.benchmarking.configuration.column_headings.exemplar_peak_kw'),
        t('analytics.benchmarking.configuration.column_headings.saving_if_match_exemplar_£')
      ]
    end

    def key
      :electricity_peak_kw_per_pupil
    end

    def advice_page_key
      :electricity_intraday
    end

    def load_data
      Comparison::ElectricityPeakKwPerPupil.where(school: @schools)
                                           .where.not(average_school_day_last_year_kw_per_floor_area: nil)
                                           .order(average_school_day_last_year_kw_per_floor_area: :desc)
    end

    def create_charts(results)
      create_single_number_chart(results, :average_school_day_last_year_kw_per_floor_area, 1000.0, 'w_floor_area', 'w')
    end
  end
end
