module Comparisons
  class GasTargetsController < BaseController
    include Targets

    private

    def key
      :gas_targets
    end

    def advice_page_key
      :gas_long_term
    end

    def model
      Comparison::GasTargets
    end
  end
end
