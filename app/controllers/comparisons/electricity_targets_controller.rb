module Comparisons
  class ElectricityTargetsController < Comparisons::Shared::TargetsController
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
