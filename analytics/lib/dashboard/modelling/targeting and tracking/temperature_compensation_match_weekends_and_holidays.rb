# Originally used for gas / storage heater target meters for :day calculations
class TargetMeterTemperatureCompensatedDailyDayTypeMatchWeekendsAndHolidays < TargetMeterTemperatureCompensatedDailyDayTypeBase

  private

  # try to match holiday switch on and off rules applied in previous
  # years for holidays and weekends
  def should_heating_be_on?(synthetic_date, target_date, target_temperature, synthetic_amr_data)
    case holidays.day_type(target_date)
    when :schoolday
      target_temperature < RECOMMENDED_HEATING_ON_TEMPERATURE
    when :holiday
      should_heating_be_on_on_holiday?(target_date, synthetic_amr_data)
    when :weekend
      should_heating_be_on_at_weekend?(synthetic_date, synthetic_amr_data)
    else
      raise EnergySparksUnexpectedStateException, "Unexpected dat type #{holidays.day_type(synthetic_date)}"
    end
  end

  # find corresponding day in holiday in the previous year and determine whether heating was on
  # - looks for matching either weekday or weekend
  # - doesn't match weekdays with weekdays e.g. Monday with Monday - so not perfect if both
  #   holidays don't start on same day and/or building thermally massive
  # - wraps %/modulus if previous holiday longer/shorter than target holiday length
  # TODO(PH, 2Sep2021) - might be better temperature weighted by more complex to implement, support - for limited benefit?
  def should_heating_be_on_on_holiday?(target_date, synthetic_amr_data)
    target_holiday    = meter_collection.holidays.holiday(target_date)
    previous_holiday  = meter_collection.holidays.same_holiday_previous_year(target_holiday)

    if previous_holiday.nil?
      # typically this should only occur on more obscure shorter holidays
      # e.g. May Day public holiday if the school's calendars are setup correctly
      logger.info "Unable to find matching holiday for #{target_date} in previous year"
      return false
    end

    target_date_at_weekend = weekend?(target_date)

    historic_heating_on_xNdays = heating_on_by_type(previous_holiday, target_date_at_weekend, synthetic_amr_data)

    target_holiday_day_index = day_index_into_holiday(target_holiday, target_date, target_date_at_weekend)

    heating_on =  if historic_heating_on_xNdays.empty?
                    # should only occur if holiday setup badly
                    false
                  else
                    historic_heating_on_xNdays[target_holiday_day_index % historic_heating_on_xNdays.length]
                  end

    heating_on
  end

  def day_index_into_holiday(holiday, date, weekend)
    count = 0
    (holiday.start_date..holiday.end_date).each do |holiday_date|
      if weekend == weekend?(holiday_date)
        count += 1
        return count if holiday_date == date
      end
    end
    nil
  end

  def weekend?(date)
    [0, 6].include?(date.wday)
  end

  def heating_on_by_type(period, weekend, synthetic_amr_data)
    @heating_on_by_type ||= {}
    @heating_on_by_type[period.type] ||= {}
    @heating_on_by_type[period.type][weekend] ||= heating_on_by_type_xNDays(period, weekend, synthetic_amr_data)
  end

  def heating_on_by_type_xNDays(period, weekend, synthetic_amr_data)
    model = local_heating_model(synthetic_amr_data)

    (period.start_date..period.end_date).map do |date|
      weekend == weekend?(date) ? model.heating_on?(date) : nil
    end.compact
  end

  # for weekends just determine whether the heating was on on the
  # corresponding weekend of the previous year, this slightly simplistic
  # assumption is not ideal as it ignores holidays, and heating which
  # was on during term time at weekends might not be on during weekend holidays
  def should_heating_be_on_at_weekend?(synthetic_date, synthetic_amr_data)
    model = local_heating_model(synthetic_amr_data)
    model.heating_on?(synthetic_date)
  end
end
