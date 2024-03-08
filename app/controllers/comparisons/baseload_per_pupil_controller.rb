# frozen_string_literal: true

module Comparisons
  class BaseloadPerPupilController < BaseController
    private

    def headers
      [
        t('analytics.benchmarking.configuration.column_headings.school'),
        t('analytics.benchmarking.configuration.column_headings.baseload_per_pupil_w'),
        t('analytics.benchmarking.configuration.column_headings.last_year_cost_of_baseload'),
        t('analytics.benchmarking.configuration.column_headings.average_baseload_kw'),
        t('analytics.benchmarking.configuration.column_headings.baseload_percent'),
        t('analytics.benchmarking.configuration.column_headings.saving_if_matched_exemplar_school')
      ]
    end

    def key
      :baseload_per_pupil
    end

    def advice_page_key
      :baseload
    end

    def load_data
      Comparison::BaseloadPerPupil.where(school: @schools).where.not(one_year_baseload_per_pupil_kw: nil).order(one_year_baseload_per_pupil_kw: :desc)
    end

    def create_charts(results)
      create_single_number_chart(results, :one_year_baseload_per_pupil_kw, 1000.0, 'baseload_per_pupil_w', 'w')
    end
  end
end
