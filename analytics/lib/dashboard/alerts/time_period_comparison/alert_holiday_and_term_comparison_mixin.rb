module AlertHolidayAndTermComparisonMixin
  def timescale
    'custom'
  end

  protected def current_period_name(period)
    'last holiday'
  end

  protected def previous_period_name(period)
    'last week of term'
  end

  protected def last_two_periods(asof_date)
    [current_period_config(asof_date), previous_period_config(asof_date)]
  end

  def current_period_config(asof_date = @asof_date)
    holiday = @school.holidays.find_previous_or_current_holiday(asof_date)
    # need to call this method from AlertHolidayComparisonBase to truncate range as its
    # not called directly by AlertArbitraryPeriodComparisonBase
    #
    # Might be truncated to nil if the period is after meter data, so also ensures
    # that schools with very lagging data are ignored
    truncate_period_to_available_meter_data(holiday)
  end

  def previous_period_config(asof_date = @asof_date)
    holiday = @school.holidays.find_previous_or_current_holiday(asof_date)
    # 0 is the last week before the holiday, counting in reverse order
    sunday, saturday, week_count = @school.holidays.nth_school_week(holiday.start_date, 0)
    # reduce period by 1 day to avoid overlap
    period = SchoolDatePeriod.new(:analysis, 'Previous period', sunday, holiday.start_date - 1)
    # need to call this method from AlertHolidayComparisonBase to truncate range as its
    # not called directly by AlertArbitraryPeriodComparisonBase
    #
    # Might be truncated to nil if the period is after meter data, so also ensures
    # that schools with very lagging data are ignored
    truncate_period_to_available_meter_data(period)
  end

  protected def comparison_chart
    nil
  end

  # We just need enough data in a period, doesnt matter if the meter data is
  # lagging
  protected def max_days_out_of_date_while_still_relevant
    nil
  end

  private def enough_days_data(days)
    days >= 1
  end
end
