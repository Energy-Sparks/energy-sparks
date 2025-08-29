# frozen_string_literal: true

module Comparisons
  class ChangeInGasSinceLastYearController < Shared::ChangeInHeatingSinceLastYearController
    include ComparisonsHelper

    private

    def key
      :change_in_gas_since_last_year
    end

    def model
      Comparison::ChangeInGasSinceLastYear
    end

    def create_charts(results)
      create_single_number_chart(results, :temperature_adjusted_percent, 100.0, 'change_in_kwh_pct', 'percent')
    end
  end
end
