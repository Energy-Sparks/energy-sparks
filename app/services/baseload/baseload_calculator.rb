# frozen_string_literal: true

module Baseload
  class BaseloadCalculator
    def initialize(amr_data)
      @amr_data = amr_data
    end

    # Create a baseload calculator suitable for this school. If we are using Solar PV data, as indicated by the flag,
    # we use an alternate method as there are issues e.g. with underestimated early morning usage
    def self.calculator_for(amr_data, solar_pv)
      klass = solar_pv ? AroundMidnightBaseloadCalculator : StatisticalBaseloadCalculator
      klass.new(amr_data)
    end

    # Calculates the average baseload in kw between 2 dates
    def average_baseload_kw_date_range(date1 = up_to_1_year_ago, date2 = @amr_data.end_date)
      date_divisor = (date2 - date1 + 1)
      return 0.0 if date_divisor.zero?

      # take average then convert from kWh to kW
      baseload_kwh_date_range(date1, date2) / date_divisor / 24.0
    end

    # Calculates total baseload in kwh between 2 dates
    def baseload_kwh_date_range(date1, date2)
      total_kw = 0.0
      (date1..date2).each do |date|
        total_kw += baseload_kw(date)
      end
      total_kw * 24.0 # convert from kw to kwh
    end

    private

    def up_to_1_year_ago
      @amr_data.up_to_1_year_ago
    end
  end
end
