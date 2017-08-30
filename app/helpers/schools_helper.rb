module SchoolsHelper
  def daily_usage_chart(supply, first_date, to_date, meter = nil)
    column_chart(
      compare_daily_usage_school_path(supply: supply, first_date: first_date, to_date: to_date, meter: meter),
      id: "chart",
      xtitle: 'Date',
      ytitle: 'kWh',
      height: '500px',
      colors: colours_for_supply(supply),
      library: {
          yAxis: {
              lineWidth: 1
          }
      }
    )
  end

  def compare_hourly_usage_chart(supply, first_date, to_date, meter = nil)
    line_chart(compare_hourly_usage_school_path(supply: supply, first_date: first_date, to_date: to_date, meter: meter),
          id: "chart",
          xtitle: 'Time of day',
          ytitle: 'kW',
          height: '500px',
          colors: colours_for_supply(supply),
          library: {
            xAxis: {
                tickmarkPlacement: 'on'
            },
            yAxis: {
                lineWidth: 1,
                tickInterval: 2
            }
          }
    )
  end

  def colours_for_supply(supply)
    supply == "electricity" ? %w(#3bc0f0 #232b49) : %w(#ffac21 #ff4500)
  end

  def hourly_usage_to_precision(school, supply, date, meter, scale = :kw, to_precision = 1)
    precision = lambda { |reading| [reading[0], number_with_precision(reading[1], precision: to_precision)] }
    school.hourly_usage_for_date(supply: supply,
      date: date,
      meter: meter,
      scale: scale
    ).map(&precision)
  end

  # get n days average daily usage
  def average_usage(supply, window = 7)
    last_n_days = @school.last_n_days_with_readings(supply, window)
    return nil unless last_n_days
    # return the latest date and average usage
    # average = daily usage figures, summed, divided by window
    [last_n_days.last, @school.daily_usage(supply: supply, dates: last_n_days)
                                 .inject(0) { |a, e| a + e[1] } / window
    ]
  end

  def last_full_week(supply)
    last_full_week = @school.last_full_week(supply)
    last_full_week.present? ? last_full_week : nil
  end

  # get day last week with most usage
  def day_most_usage(supply)
    day = @school.day_most_usage(supply)
    day.nil? ? '?' : day[0].strftime('%A')
  end
end
