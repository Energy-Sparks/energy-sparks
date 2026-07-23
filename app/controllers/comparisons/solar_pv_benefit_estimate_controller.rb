module Comparisons
  class SolarPvBenefitEstimateController < BaseController
    private

    def headers
      Comparison::SolarPvBenefitEstimate.report_headers
    end

    def key
      :solar_pv_benefit_estimate
    end

    def advice_page_key
      :solar_pv
    end

    def load_data
      Comparison::SolarPvBenefitEstimate.for_schools(@schools).with_data.sort_default
    end
  end
end
