# frozen_string_literal: true

# correct for reduced consumption during the 3rd lockdown (Jan-Mar 2021)
# - by using data from Jan-Mar 2020 if available
# - or using data from Oct - Dec 2020 (mirrored)
class TargetsService
  class Covid3rdLockdownElectricityCorrection < MissingEnergyFittingBase
    class Unexpected3rdLockdownCOVIDAdjustment < StandardError; end
    MAX_CHANGE_BEFORE_MIRRORING = 0.05
    include Logging

    def initialize(meter, holidays)
      super(meter.amr_data, holidays)
      @country = meter.meter_collection.country
      @lockdown_start_date, @lockdown_end_date = self.class.determine_3rd_lockdown_dates(meter.meter_collection.country)
    end

    def enough_data?
      enough_data_for_annual_mirror? || enough_data_for_seasonal_mirror?
    end

    def lockdown_date_ranges
      [@lockdown_start_date..@lockdown_end_date]
    end

    # returns a 3 part hash: { :amr_data => 1+year's amr data , feedback: {:percent_real_data => Float, :adjustments_applied => text }}
    def adjusted_amr_data
      case mirroring_rules
      when :no_change_not_a_big_enough_reduction
        unadjusted_amr_data
      when :replace_with_jan_mar_2020, :replace_with_oct_dec_2020_reversed
        adjusted_amr_data_private
      else
        raise Unexpected3rdLockdownCOVIDAdjustment, mirroring_rules
      end
    end

    def self.determine_3rd_lockdown_dates(country) # sunday to saturday dates only
      case country
      when :england, :wales
        [Date.new(2021, 1, 3), Date.new(2021, 3, 6)]
      when :scotland
        [Date.new(2021, 1, 3), Date.new(2021, 3, 27)]
      end
    end

    private

    def alternative_date(date)
      @alternative_date_cache ||= {}
      return nil unless date.between?(@lockdown_start_date, @lockdown_end_date) # don't bother caching it

      @alternative_date_cache[date] ||= calculate_alternative_date(date)
    end

    def enough_data_for_annual_mirror?
      @amr_data.start_date <= @lockdown_start_date - 365 &&
        @amr_data.end_date >= @lockdown_end_date
    end

    def adjustment_description
      msg = 'Correcting for 3rd lockdown (Jan-Mar 2021) electricity kWh school day reduction. '
      msg += "Reduction v. Jan-Mar 2020 #{FormatUnit.format(:percent, lockdown_versus_previous_year_percent_change,
                                                            :text)}. "
      msg += "Reduction v. Oct-Dec 2020 #{FormatUnit.format(:percent, lockdown_versus_mirror_percent_change, :text)}. "
      msg += "Will apply a correction if change > #{MAX_CHANGE_BEFORE_MIRRORING * 100.0}%. "

      rule_description = {
        replace_with_jan_mar_2020: 'Copying Jan-Mar 2020 - over reduced Jan-Mar 2021 lockdown data',
        replace_with_oct_dec_2020_reversed: 'Copying Oct-Dec 2020 (reversed) - over reduced Jan-Mar 2021 lockdown data',
        no_change_not_a_big_enough_reduction: 'Not correcting as hasnt dropped enough',
        not_enough_data: 'Not enough data'
      }

      msg += "Using the following adjustment #{rule_description[mirroring_rules]}"
      msg
    end

    def mirroring_rules
      @mirroring_rules ||= calculate_mirroring_rules
    end

    def lockdown_versus_mirror_percent_change
      @lockdown_versus_mirror_percent_change ||= reduction_percent(:lockdown_weeks, :mirror_weeks)
    end

    def lockdown_versus_previous_year_percent_change
      @lockdown_versus_previous_year_percent_change ||= reduction_percent(:lockdown_weeks, :previous_year_weeks)
    end

    def enough_data_for_seasonal_mirror?
      @amr_data.start_date <= mirrored_weeks_dates[:mirror_weeks].last.first &&
        @amr_data.end_date >= mirrored_weeks_dates[:lockdown_weeks].last.last
    end

    def adjusted_amr_data_private
      @adjusted_amr_data_private ||= calculate_adjust_amr_data
    end

    def calculate_adjust_amr_data
      amr_copy = AMRData.copy_amr_data(@amr_data)
      adjusted_day_count = 0

      (@lockdown_start_date..@lockdown_end_date).each do |date|
        substitute_date = alternative_date(date)
        next if substitute_date.nil?

        one_day = @amr_data.days_amr_data(substitute_date)
        substituted_one_day = OneDayAMRReading.new(one_day.meter_id, date, 'COVD', substitute_date, DateTime.now,
                                                   one_day.kwh_data_x48.clone)
        amr_copy.add(date, substituted_one_day)
        adjusted_day_count += 1
      end

      {
        amr_data: amr_copy,
        feedback: {
          percent_real_data: (365 - adjusted_day_count) / 365.0,
          adjustments_applied: adjustment_description,
          percent_reduction_versus_Oct_Dec_2020: lockdown_versus_mirror_percent_change,
          percent_reduction_versus_Jan_Mar_2020: lockdown_versus_previous_year_percent_change,
          rule: mirroring_rules
        }
      }
    end

    def unadjusted_amr_data
      {
        amr_data: @amr_data,
        feedback: {
          percent_real_data: 1.0,
          adjustments_applied: 'No 3rd Lockdown electricity amr data adjustment applied as not enough of a reduction during the lockdown',
          percent_reduction_versus_Oct_Dec_2020: lockdown_versus_mirror_percent_change,
          percent_reduction_versus_Jan_Mar_2020: lockdown_versus_previous_year_percent_change,
          rule: mirroring_rules
        }
      }
    end

    def calculate_alternative_date(date)
      return nil if holiday_or_weekend?(date) # assume holidays and weekends not impacted

      case mirroring_rules
      when :no_change_not_a_big_enough_reduction
        nil
      when :not_enough_data
        # TODO(PH, 3Aug2021) implement interpolation alternative algorithm
        nil
      when :replace_with_jan_mar_2020
        alternative_jan_mar_2020_date(date)
      when :replace_with_oct_dec_2020_reversed
        alternative_oct_dec_2020_date(date)
      end
    end

    def alternative_jan_mar_2020_date(date)
      alternative_by_type_date(date, :previous_year_weeks)
    end

    def alternative_oct_dec_2020_date(date)
      alternative_by_type_date(date, :mirror_weeks)
    end

    def alternative_by_type_date(date, type)
      mirrored_weeks_dates[:lockdown_weeks].each_with_index do |lockdown_week, index|
        if date.between?(lockdown_week.first, lockdown_week.last)
          return alternative_date_in_week(date, mirrored_weeks_dates[type][index])
        end
      end
      nil
    end

    def alternative_date_in_week(date, substitute_week)
      substitute_day = substitute_week.first + date.wday

      if holiday_or_weekend?(substitute_day)
        # if in the low probability of this being a holiday
        # then pick another random school day in the week to substitute
        substitute_week.each do |substitute_date|
          return substitute_date unless holiday_or_weekend?(substitute_date)
        end
      else
        substitute_day
      end
    end

    def holiday_or_weekend?(date)
      %i[holiday weekend].include?(@holidays.day_type(date))
    end

    def calculate_mirroring_rules
      if !lockdown_versus_previous_year_percent_change.nan? &&
         lockdown_versus_previous_year_percent_change > MAX_CHANGE_BEFORE_MIRRORING
        :replace_with_jan_mar_2020
      elsif !lockdown_versus_mirror_percent_change.nan? &&
            lockdown_versus_mirror_percent_change > MAX_CHANGE_BEFORE_MIRRORING
        :replace_with_oct_dec_2020_reversed
      elsif !lockdown_versus_previous_year_percent_change.nan? ||
            !lockdown_versus_mirror_percent_change.nan?
        :no_change_not_a_big_enough_reduction
      else
        :not_enough_data
      end
    end

    def reduction_percent(type_1, type_2)
      paired_weeks = compare_mirrored_week_average_school_day_kwhs(type_1, type_2)
      average_lockdown_kwh = paired_weeks.map { |l_v_m| l_v_m[0] }.sum / paired_weeks.length
      average_mirrored_kwh = paired_weeks.map { |l_v_m| l_v_m[1] }.sum / paired_weeks.length
      (average_mirrored_kwh - average_lockdown_kwh) / average_mirrored_kwh
    end

    def compare_mirrored_week_average_school_day_kwhs(type_1, type_2)
      mirrored_weeks_dates[type_1].map.with_index do |lockdown_week, index|
        mirrored_week = mirrored_weeks_dates[type_2][index]
        [
          average_kwh_for_daytype(lockdown_week.first, lockdown_week.last),
          average_kwh_for_daytype(mirrored_week.first, mirrored_week.last)
        ]
      end
    end

    def mirrored_weeks_dates
      @mirrored_weeks_dates ||= calculate_mirrored_week_dates
    end

    def calculate_mirrored_week_dates
      starting_sunday, ending_saturday = self.class.determine_3rd_lockdown_dates(@country)
      lockdown_weeks = classify_weeks(starting_sunday, ending_saturday, :schoolday)

      mirror_end_saturday = starting_sunday - 1
      mirror_start_sunday = mirror_end_saturday - 6 - ((lockdown_weeks.length + 4) * 7) # 4 = margin for differing holiday arrangements in each year
      mirror_weeks = classify_weeks(mirror_start_sunday, mirror_end_saturday,
                                    :schoolday).reverse[0...lockdown_weeks.length]

      year_before_starting_sunday = starting_sunday - 364
      year_before_ending_saturday = year_before_starting_sunday + 6 + ((lockdown_weeks.length + 2) * 7) # plus 2= margin for different holidat arrangements in each year
      previous_year = classify_weeks(year_before_starting_sunday, year_before_ending_saturday,
                                     :schoolday)[0...lockdown_weeks.length]

      {
        lockdown_weeks: lockdown_weeks,
        mirror_weeks: mirror_weeks,
        previous_year_weeks: previous_year
      }
    end

    def classify_weeks(starting_sunday, ending_saturday, type)
      weeks = []
      (starting_sunday..ending_saturday).each_slice(7) do |days|
        weeks.push(days.first..days.last) if week_type(days.first + 1, days.last - 1) == type
      end
      weeks
    end

    def week_type(start_monday, end_friday)
      type_count = { schoolday: 0, weekend: 0, holiday: 0 }
      (start_monday..end_friday).each do |date|
        type_count[@holidays.day_type(date)] += 1
      end
      type_count.sort_by { |_daytype, count| -count }.to_h.keys[0]
    end
  end
end
