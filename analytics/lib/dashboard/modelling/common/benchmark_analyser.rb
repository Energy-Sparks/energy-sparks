# Miscellaneous analysis used for benchmarking
module BenchmarkAnalyser
  class AnalyseDropInSummerHolidayBaseload
    def initialize(meter_collection)
      @meter_collection = meter_collection
    end

    def analyse
      unless @meter_collection.aggregated_electricity_meters.nil?
        analyse_baseload_for_summer_kitchen_refrigeration_switchoff
      end
    end

    def analyse_baseload_for_summer_kitchen_refrigeration_switchoff
      meter = @meter_collection.aggregated_electricity_meters
      amr = meter.amr_data

      summer_holidays_with_savings = []

      summer_holidays = @meter_collection.holidays.find_all_summer_holidays_date_range(amr.start_date, amr.end_date)

      summer_holidays.each do |summer_holiday|
        begin
          days, drop, change_before_after_holiday = days_dropin_summer_holiday_baseload(amr, summer_holiday)
          summer_holidays_with_savings.push([summer_holiday.start_date.year, days, drop, change_before_after_holiday])
        rescue EnergySparksNotEnoughDataException => e
          puts e
        end
      end

      unless summer_holidays_with_savings.empty?
        summer_holidays_with_savings.each do |year, days, drop, change_before_after_holiday|
          comment = change_before_after_holiday.nil? ? '' : " warning change between before and after holiday of #{change_before_after_holiday}"
          puts "Summer saving: #{year} for  #{days} days of #{drop.round(2)} #{year}" + comment
        end
      end
    end

    private def days_dropin_summer_holiday_baseload(amr, summer_holiday, drop_criteria = 0.4)
      before_after_baseload_change = nil
      baseload_before = baseload_before_holiday(amr, summer_holiday)
      baseload_after = baseload_after_holiday(amr, summer_holiday)

      # analysis might not be valid if he school day baseload changes between before
      # and after the holidays, so flag up the issue
      if baseload_change(baseload_before, baseload_after).magnitude > drop_criteria
        before_after_baseload_change = [baseload_before, baseload_after]
      end

      baseloads = [baseload_before, baseload_after].compact # remove nils
      average_schoolday_baseload = baseloads.inject(:+) / baseloads.length

      days, average_kw_drop = days_baseload_below_kw(amr, summer_holiday.start_date, summer_holiday.end_date, average_schoolday_baseload, drop_criteria)

      [days, average_kw_drop, before_after_baseload_change]
    end

    private def days_baseload_below_kw(amr, start_date, end_date, average_kw, drop_criteria)
      days_below = []
      (start_date..end_date).each do |date|
        kw_today = amr.overnight_baseload_kw(date)
        if kw_today < (average_kw - drop_criteria)
          days_below.push(average_kw - kw_today)
        end
      end

      if days_below.empty?
        [0, 0.0]
      else
        average = days_below.inject(:+) / days_below.size
        [days_below.length, average]
      end
    end

    private def baseload_change(bl1, bl2)
      return 0.0 if bl1.nil? || bl2.nil?
      (bl1 - bl2)/bl1
    end

    private def baseload_before_holiday(amr, summer_holiday)
      start_date = summer_holiday.start_date - 30
      if amr.start_date > start_date
        nil
      else
        amr.average_overnight_baseload_kw_date_range(start_date, summer_holiday.start_date - 1)
      end
    end

    private def baseload_after_holiday(amr, summer_holiday)
      end_date = summer_holiday.end_date + 30
      if amr.end_date < end_date
        nil
      else
        amr.average_overnight_baseload_kw_date_range(summer_holiday.end_date + 1, end_date)
      end
    end
  end
end
