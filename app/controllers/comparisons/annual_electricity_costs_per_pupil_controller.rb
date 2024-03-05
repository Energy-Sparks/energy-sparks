module Comparisons
  class AnnualElectricityCostsPerPupilController < BaseController
    private

    def key
      :annual_electricity_costs_per_pupil
    end

    def advice_page_key
      :electricity_long_term
    end

    def load_data
      Comparison::AnnualElectricityCostsPerPupil.where(school: @schools).where.not(one_year_electricity_per_pupil_gbp: nil).order(one_year_electricity_per_pupil_gbp: :desc)
    end
  end
end
