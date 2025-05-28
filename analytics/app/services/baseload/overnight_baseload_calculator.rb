# frozen_string_literal: true

module Baseload
  # Alternative approach for calculating daily baseload
  #
  # Assumes that the school is using minimal power for other purposes during the
  # late evening, between 8.30pm and midnight. The correspond to half-hourly periods
  # 41 through to 47.
  #
  # This approach is used where we are using modelled solar data from Sheffield, as there
  # are issues with the modelling that causes the early morning generation to be under-estimated,
  # e.g. if solar panels have different orientation. This results in the baseload being
  # underestimated. The evening periods will not suffer from this same problem.
  #
  # Sampling in the early morning instead is problematic as other consumers startup
  # (e.g. boiler pumps, often from around 01:00).
  class OvernightBaseloadCalculator < BaseloadCalculator
    def baseload_kw(date, data_type = :kwh)
      overnight_baseload_kw(date, data_type)
    end

    # Calculates the average baseload in kw between two dates
    def average_overnight_baseload_kw_date_range(date1 = start_date, date2 = end_date)
      overnight_baseload_kw_date_range(date1, date2) / (date2 - date1 + 1)
    end

    private

    def overnight_baseload_kw(date, data_type = :kwh)
      raise EnergySparksNotEnoughDataException, "Missing electric data for #{date}" if @amr_data.date_missing?(date)

      range = (41..47)
      total_kwh = total_kwh_within_hh_range(date, range, data_type)
      # convert to kW and produce average
      total_kwh * 2.0 / range.size
    end

    def total_kwh_within_hh_range(date, range, data_type = :kwh)
      total_kwh = 0.0
      range.each do |halfhour_index|
        total_kwh += @amr_data.kwh(date, halfhour_index, data_type)
      end
      total_kwh
    end

    def overnight_baseload_kw_date_range(date1, date2)
      total = 0.0
      (date1..date2).each do |date|
        total += overnight_baseload_kw(date)
      end
      total
    end
  end
end
