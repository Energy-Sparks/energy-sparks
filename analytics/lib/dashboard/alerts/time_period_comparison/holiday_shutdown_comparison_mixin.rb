# Variation of ArbitraryPeriodComparisonMixIn, intended to be mixed in on top.
# Uses a holiday date, e.g. Good Friday, to find that period and the previous week.
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
    period = SchoolDatePeriod.new(:analysis, 'Previous period', sunday, holiday.start_date - 1)
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
