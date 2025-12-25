# frozen_string_literal: true

# for targeting and tracking:
# - where there is less than 1 year of gas amr_data
# - and the gas modelling is not working
# estimate a complete year's worth of gas data using degree days

class TargetMeter
  class MissingGasDegreeDayEstimation < MissingGasEstimationBase
    def complete_year_amr_data
      fill_in_missing_data_by_daytype(:holiday)
      fill_in_missing_data_by_daytype(:weekend)
      percent_real_data = fill_in_missing_schoolday_data

      {
        amr_data: one_year_amr_data,
        feedback: {
          percent_real_data: percent_real_data,
          adjustments_applied: 'less than 1 years data, filling in missing using degree day adjustment (no modelling data available)',
          degree_days_remaining: @degree_days_remaining,
          degree_days: @total_degree_days,
          total_real_kwh: @total_kwh_so_far,
          annual_estimated_kwh: @annual_kwh,
          percent_synthetic_kwh: (@annual_kwh - @total_kwh_so_far) / @annual_kwh,
          synthetic_days: @adjustment_count,
          rule: self.class.name
        }
      }
    end

    private

    def fill_in_missing_schoolday_data
      @adjustment_count = 0
      @total_kwh_so_far = calculate_holey_amr_data_total_kwh(one_year_amr_data)
      remaining_kwh = @annual_kwh - @total_kwh_so_far
      dd = calculate_degree_days(one_year_amr_data)
      @degree_days_remaining = dd[:remaining]
      @total_degree_days = dd[:total]
      school_day_profile_x48 = average_profile_for_day_type_x48(:schoolday)
      school_day_profile_total_kwh = school_day_profile_x48.sum

      @target_dates.missing_date_range.each do |date|
        next if @holidays.day_type(date) != :schoolday || one_year_amr_data.date_exists?(date)

        degree_days = @meter.meter_collection.temperatures.degree_days(date)

        predicted_kwh = remaining_kwh * (degree_days / @degree_days_remaining)

        scale = predicted_kwh / school_day_profile_total_kwh

        add_scaled_days_kwh(date, scale, school_day_profile_x48)

        @adjustment_count += 1
      end

      (365 - @adjustment_count) / 365.0
    end

    def calculate_degree_days(one_year_amr_data)
      remaining_degree_days = 0.0
      total_degree_days = 0.0
      @target_dates.missing_date_range.each do |date|
        dd = @meter.meter_collection.temperatures.degree_days(date)
        remaining_degree_days += dd unless one_year_amr_data.date_exists?(date)
        total_degree_days += dd
      end
      { remaining: remaining_degree_days, total: total_degree_days }
    end
  end
end
