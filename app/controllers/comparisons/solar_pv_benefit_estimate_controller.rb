module Comparisons
  class SolarPvBenefitEstimateController < BaseController
    private

    def key
      :solar_pv_benefit_estimate
    end

    def advice_page_key
      :solar_pv
    end

    def load_data
      Comparison::SolarPvBenefitEstimate.where(school: @schools).with_data.sort_default
    end
  end
end
