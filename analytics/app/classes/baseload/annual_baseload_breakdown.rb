# frozen_string_literal: true

module Baseload
  # Provides access to results of a years baseload calculations for an
  # aggregated electricity meter
  class AnnualBaseloadBreakdown
    attr_reader :year,
                :average_annual_baseload_kw,
                :meter_data_available_for_full_year

    def initialize(
      year:,
      average_annual_baseload_kw:,
      meter_data_available_for_full_year:
    )
      @year = year
      @average_annual_baseload_kw = average_annual_baseload_kw
      @meter_data_available_for_full_year = meter_data_available_for_full_year
    end
  end
end
