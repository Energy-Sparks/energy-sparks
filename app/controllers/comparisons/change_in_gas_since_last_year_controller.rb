# frozen_string_literal: true

module Comparisons
  class ChangeInGasSinceLastYearController < Shared::ChangeInHeatingSinceLastYearController
    private

    def key
      :change_in_gas_since_last_year
    end

    def model
      Comparison::ChangeInGasSinceLastYear
    end
  end
end
