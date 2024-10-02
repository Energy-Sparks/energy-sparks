# frozen_string_literal: true

module Baseload
  class BaseloadCalculator
    def initialize(amr_data)
      @amr_data = amr_data
    end

    # Create a baseload calculator suitable for this school. If we are using
    # Sheffield Solar PV data, we use an alternate method as there are issues with
    # the Sheffield data resulting underestimated early morning usage
    #
    def self.for_meter(dashboard_meter)
      # return calculator cached by the amr data
      dashboard_meter.amr_data.baseload_calculator(dashboard_meter.sheffield_simulated_solar_pv_panels?)
    end

    # Create a baseload calculator suitable for this school. If we are using
    # Sheffield Solar PV data, as indicated by the flag, we use an alternate
    # method as there are issues with the Sheffield data resulting underestimated
    # early morning usage
    def self.calculator_for(amr_data, sheffield_solar_pv)
      # create a new calculator
      sheffield_solar_pv ? BaseloadCalculator.overnight_calculator(amr_data) : StatisticalBaseloadCalculator.new(amr_data)
    end

    def self.overnight_calculator(amr_data)
      if ENV['FEATURE_FLAG_MIDNIGHT_BASELOAD'] == 'true'
        Baseload::AroundMidnightBaseloadCalculator.new(amr_data)
      else
        Baseload::OvernightBaseloadCalculator.new(amr_data)
      end
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
      [@amr_data.end_date - 365, @amr_data.start_date].max
    end
  end
end
