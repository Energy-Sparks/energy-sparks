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
    last_full_week = @school.last_full_week(supply)
    return nil unless last_full_week
    # return the Friday's date and avarage usage
    # average = daily usage figures, summed, divided by 5
    [last_full_week.last, @school.daily_usage(supply, last_full_week)
                                 .inject(0) { |a, e| a + e[1] } / 5
    ]
  end

  # get day last week with most usage
  def day_most_usage(supply)
    day = @school.day_most_usage(supply)
    day.nil? ? '?' : day[0].strftime('%^A')
  end
end
