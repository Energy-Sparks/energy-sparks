# frozen_string_literal: true

module Baseload
  class IntraweekVariation
    # days_kw: { day_num => kw }
    def initialize(days_kw:)
      @days_kw = days_kw
    end

    # returns day of the week with minimum baseload
    # consistent with `Day.wday`
    def min_day
      @days_kw.key(min_day_kw)
    end

    # return baseload for day with lowest baseload
    def min_day_kw
      @days_kw.values.min
    end

    # returns day of the week with maximum baseload
    # consistent with `Day.wday`
    def max_day
      @days_kw.key(max_day_kw)
    end

    # return baseload for day with highest baseload
    def max_day_kw
      @days_kw.values.max
    end

    # return % difference in baseload between highest and lowest days
    def percent_intraday_variation
      min = min_day_kw
      return 0.0 if min.zero?

      (max_day_kw - min) / min
    end

    # calculate potential weekly saving if baseload for all days was reduced to the current minimum
    def week_saving_kwh
      min = min_day_kw
      @days_kw.values.map do |day_kw|
        (day_kw - min) * 24.0
      end.sum
    end

    def annual_cost_kwh
      week_saving_kwh * 52.0 # ignore holiday calc
    end
  end
end
