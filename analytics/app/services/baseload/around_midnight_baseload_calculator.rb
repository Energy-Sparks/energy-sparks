# frozen_string_literal: true

require_relative './baseload_calculator'

module Baseload
  # Alternative approach for calculating daily baseload
  #
  # Assumes school uses minimal power close to, and shortly after midnight. This
  # is broadly the same as the OvernightBaseloadCalculator but with a slightly different
  # time period.
  #
  # The reason for having an alternate approach is the same: when using the Sheffield solar
  # data we can underestimate baseload if we just use the periods with lowest usage.
  #
  # This version tweaks the overnight algorithm to reduce likelihood of overlap with
  # community baseload periods.
  #
  # Uses 22:00-23:30 (44..47) and midnight to 2am (0..3)
  class AroundMidnightBaseloadCalculator < BaseloadCalculator
    def baseload_kw(date, data_type = :kwh)
      around_midnight_baseload_kw(date, data_type)
    end

    private

    def around_midnight_baseload_kw(date, data_type = :kwh)
      raise EnergySparksNotEnoughDataException, "Missing electric data for #{date}" if @amr_data.date_missing?(date)

      total_kwh = total_kwh_within_hh_range(date, (44..47), data_type)
      total_kwh += total_kwh_within_hh_range(date, (0..3), data_type)
      # convert to kW and produce average
      total_kwh * 2.0 / 8.0
    end

    def total_kwh_within_hh_range(date, range, data_type = :kwh)
      total_kwh = 0.0
      range.each do |halfhour_index|
        total_kwh += @amr_data.kwh(date, halfhour_index, data_type)
      end
      total_kwh
    end
  end
end
