# frozen_string_literal: true

module Comparisons
  class BaseloadPerPupilController < BaseController
    private

    def headers
      Comparison::BaseloadPerPupil.report_headers
    end

    def key
      :baseload_per_pupil
    end

    def advice_page_key
      :baseload
    end

    def load_data
      Comparison::BaseloadPerPupil.for_schools(@schools).where.not(one_year_baseload_per_pupil_kw: nil).order(one_year_baseload_per_pupil_kw: :desc)
    end

    def create_charts(results)
      create_single_number_chart(results, :one_year_baseload_per_pupil_kw, 1000.0, 'baseload_per_pupil_w', 'w')
    end
  end
end
