# frozen_string_literal: true

class TargetsService
  class MissingEnergyFittingBase
    def initialize(amr_data, holidays)
      @amr_data = amr_data
      @holidays = holidays
    end

    private

    def average_kwh_for_daytype(start_date, end_date, daytype = :schoolday)
      total = 0.0
      count = 0
      (start_date..end_date).each do |date|
        next if @holidays.day_type(date) != daytype

        if date.between?(@amr_data.start_date, @amr_data.end_date)
          total += @amr_data.one_day_kwh(date)
          count += 1
        end
      end
      total / count
    end

    def fill_in_missing_data_by_daytype(daytype, date_range = @target_dates.missing_date_range,
                                        override_daytype: daytype)
      avg_profile_x48 = average_profile_for_day_type_x48(override_daytype)

      date_range.each do |date|
        next if @holidays.day_type(date) != daytype || one_year_amr_data.date_exists?(date)

        one_days_reading = OneDayAMRReading.new(@meter.mpan_mprn, date, 'TARG', nil, DateTime.now, avg_profile_x48)
        one_year_amr_data.add(date, one_days_reading)
      end
    end

    def average_profile_for_day_type_x48(daytype)
      matching_days = []
      (@amr_data.start_date..@amr_data.end_date).each do |date|
        if @holidays.day_type(date) == daytype && @amr_data.date_exists?(date)
          matching_days.push(@amr_data.days_kwh_x48(date))
        end
      end

      if matching_days.empty?
        AMRData.one_day_zero_kwh_x48
      else
        total_all_days_x48 = AMRData.fast_add_multiple_x48_x_x48(matching_days)
        AMRData.fast_multiply_x48_x_scalar(total_all_days_x48, 1.0 / matching_days.length)
      end
    end

    def calculate_holey_amr_data_total_kwh(holey_data)
      total = 0.0
      (holey_data.start_date..holey_data.end_date).each do |date|
        total += holey_data.one_day_total(date) if holey_data.date_exists?(date)
      end
      total
    end

    def scaled_day(date, scale, profile_x48)
      days_x48 = AMRData.fast_multiply_x48_x_scalar(profile_x48, scale)
      OneDayAMRReading.new(@meter.mpan_mprn, date, 'TARG', nil, DateTime.now, days_x48)
    end

    def add_scaled_days_kwh(date, scale, profile_x48)
      one_days_reading = scaled_day(date, scale, profile_x48)
      add_day(date, one_days_reading)
    end

    def add_day(date, one_days_reading)
      one_year_amr_data.add(date, one_days_reading)
    end
  end
end
