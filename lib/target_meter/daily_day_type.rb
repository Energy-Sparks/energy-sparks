# frozen_string_literal: true

# calculates average profiles from nearby days from previous year
# and then applies a scalar target reduction to them
# takes about 45ms per 365 days to calculate
# holiday averaging requirement less as don't want to have to go too far
# to a matching holiday which is too far seasonally away from the one
# we want to calculate an average profile for
class TargetMeter
  class DailyDayType < TargetMeter
    NUM_SAME_DAYTYPE_REQUIRED = {
      holiday: 4,
      weekend: 6,
      schoolday: 10
    }

    private

    def profile_x48(target_date:, synthetic_date:, synthetic_amr_data:)
      average_profile_for_day_x48(synthetic_date: synthetic_date, synthetic_amr_data: synthetic_amr_data,
                                  target_date: target_date)
    end

    def scan_days_offset(distance = 100)
      # work outwards from target day with these offsets
      # [0, 1, -1, 2, -2, 3, -3, 4, -4, 5, -5, 6, -6, 7, -7, 8, -8, 9, -9, 10, -10......-100]
      @scan_days_offset ||= [0, (1..distance).to_a.zip((-distance..-1).to_a.reverse)].flatten
    end

    def average_profile_for_day_x48(synthetic_date:, synthetic_amr_data:, target_date: nil)
      day_type = @meter_collection.holidays.day_type(synthetic_date)
      profiles_to_average = []
      scan_days_offset.each do |days_offset|
        date_offset = synthetic_date + days_offset
        if synthetic_amr_data.date_exists?(date_offset) && @meter_collection.holidays.day_type(date_offset) == day_type
          profiles_to_average.push(synthetic_amr_data.one_days_data_x48(date_offset))
        end
        break if profiles_to_average.length >= NUM_SAME_DAYTYPE_REQUIRED[day_type]
      end
      AMRData.fast_average_multiple_x48(profiles_to_average)
    end
    alias average_profile_for_day_x48_super average_profile_for_day_x48
  end
end
