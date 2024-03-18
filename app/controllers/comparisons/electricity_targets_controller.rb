module Comparisons
  class ElectricityTargetsController < BaseController
    include Targets

    private

    def key
      :electricity_targets
    end

    def advice_page_key
      :electricity_long_term
    end

    def model
      Comparison::ElectricityTargets
    end
  end
end
