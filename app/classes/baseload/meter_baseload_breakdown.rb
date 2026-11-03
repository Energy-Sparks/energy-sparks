# frozen_string_literal: true

module Baseload
  # Provides access to results of baseload calculations for
  # a range of meters and additional helper methods
  class MeterBaseloadBreakdown
    # {mpan_mprn: {kw: 0, percent: 0, £: 0} }
    def initialize(meter_breakdown:)
      @meter_breakdown = meter_breakdown
    end

    def meters
      @meter_breakdown.keys
    end

    def meters_by_baseload
      sorted = @meter_breakdown.sort_by { |_mpan, v| -v[:percent] }
      sorted.map { |v| v[0] }
    end

    def baseload_kw(mpan_mprn)
      @meter_breakdown[mpan_mprn][:kw]
    end

    def percentage_baseload(mpan_mprn)
      @meter_breakdown[mpan_mprn][:percent]
    end

    def baseload_cost_£(mpan_mprn)
      @meter_breakdown[mpan_mprn][:£]
    end

    def total_baseload_kw
      @meter_breakdown.values.map { |v| v[:kw] }.sum
    end
  end
end
