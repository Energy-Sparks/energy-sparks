require_relative 'holiday_shutdown_comparison_mixin'

module ArbitraryPeriodComparisonMixIn
  # make all instance methods because of complexities of
  # mixing in instance methods in Ruby
  def current_period_config
    c = comparison_configuration[:current_period]
    SchoolDatePeriod.new(:analysis, 'Current period', c.first, c.last)
  end

  def previous_period_config
    c = comparison_configuration[:previous_period]
    SchoolDatePeriod.new(:analysis, 'Previous period', c.first, c.last)
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
