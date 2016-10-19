module SchoolsHelper
  def daily_usage_chart(supply, to_date)
    last_reading_date = @school.last_reading_date(supply, to_date)
    column_chart(
      daily_usage_school_path(supply: supply, to_date: last_reading_date),
      xtitle: 'Date',
      ytitle: 'kWh',
      colors: %w(blue lightgrey)
    )
  end

  # get last full week's average daily usage
  def average_weekday_usage(supply)
    # get previous friday that has readings
    fri = @school.last_friday_with_readings(supply)
    return nil unless fri
    # get daily usage figures, sum them, divide by 5
    [fri, @school.daily_usage(supply, fri - 4.days..fri)
                 .inject(0) { |a, e| a + e[1] } / 5
    ]
  end
end
