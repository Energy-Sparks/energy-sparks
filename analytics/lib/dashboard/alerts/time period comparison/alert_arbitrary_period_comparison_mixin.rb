module ArbitraryPeriodComparisonMixIn
  # make all instance methods because of complexities of
  # mixing in instance methods in Ruby
  def current_period_config
    c = comparison_configuration[:current_period]
    SchoolDatePeriod.new(:alert, 'Current period', c.first, c.last)
  end

  def previous_period_config
    c = comparison_configuration[:previous_period]
    SchoolDatePeriod.new(:alert, 'Previous period', c.first, c.last)
  end

  protected def max_days_out_of_date_while_still_relevant
    comparison_configuration[:max_days_out_of_date]
  end

  protected def last_two_periods(asof_date)
    [current_period_config, previous_period_config]
  end

  def enough_days_data(days)
    days >= comparison_configuration[:enough_days_data]
  end

  def period_days(period_start, period_end)
    period_end - period_start + 1
  end

  def comparison_chart
    comparison_configuration[:comparison_chart]
  end

  def normalised_period_data(_current_period, previous_period)
    if comparison_configuration[:disable_normalisation]
      # Override to disable the default period normalisation and temperature compensation
      # applied to the previous period. Instead just return the consumption values
      # for the period, unchanged
      meter_values_period(previous_period)
    else
      super
    end
  end

  def pupil_floor_area_adjustment
    if comparison_configuration[:disable_normalisation]
      1.0
    else
      super
    end
  end
end

# Variation of the above, intended to be mixin on top
# Instead of using fixed date ranges, the configuration provides
# a holiday date, e.g. Good Friday and finds that period and the
# previous week
module HolidayShutdownComparisonMixin
  def current_period_config
    holiday_date = comparison_configuration[:holiday_date]
    holiday = @school.holidays.find_holiday(holiday_date)
    # need to call this method from AlertHolidayComparisonBase to truncate range as its
    # not called directly by AlertArbitraryPeriodComparisonBase
    #
    # Might be truncated to nil if the period is after meter data, so also ensures
    # that schools with very lagging data are ignored
    truncate_period_to_available_meter_data(holiday)
  end

  def previous_period_config
    holiday_date = comparison_configuration[:holiday_date]
    holiday = @school.holidays.find_holiday(holiday_date)
    sunday, saturday, week_count = @school.holidays.nth_school_week(holiday.start_date, school_weeks)
    # reduce period by 1 day to avoid overlap
    period = SchoolDatePeriod.new(:alert, 'Previous period', sunday, holiday.start_date - 1)
    # need to call this method from AlertHolidayComparisonBase to truncate range as its
    # not called directly by AlertArbitraryPeriodComparisonBase
    #
    # Might be truncated to nil if the period is after meter data, so also ensures
    # that schools with very lagging data are ignored
    truncate_period_to_available_meter_data(period)
  end

  # allows configuration of comparison with previous n school weeks, not just week
  # prior to holiday
  def school_weeks
    comparison_configuration[:school_weeks] || 0
  end

  def timescale
    'custom'
  end
end
