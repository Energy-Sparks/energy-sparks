# frozen_string_literal: true

module Comparisons
  class BaseloadPerPupilController < BaseController
    private

    def title_key
      'analytics.benchmarking.chart_table_config.baseload_per_pupil'
    end

    def advice_page_key
      :baseload
    end

    def load_data
      Comparison::BaseloadPerPupil.where(school: @schools).where.not(one_year_baseload_per_pupil_kw: nil).order(one_year_baseload_per_pupil_kw: :desc)
    end

    def create_charts(results)
      create_single_number_chart(results, :one_year_baseload_per_pupil_kw, 'baseload_per_pupil_w', 'w')
    end
  end
end
