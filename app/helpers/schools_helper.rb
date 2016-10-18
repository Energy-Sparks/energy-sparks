module SchoolsHelper
  def daily_usage_chart(supply, to_date)
    last_reading_date = last_reading(supply, to_date).try(:read_at).try(:to_date)
    column_chart(
      daily_usage_school_path(supply: supply, to_date: last_reading_date),
      xtitle: 'Date',
      ytitle: 'kWh',
      colors: %w(blue lightgrey)
    )
  end

private

  def last_reading(supply, to_date)
    @school.meter_readings
           .where('meters.meter_type = ?', Meter.meter_types[supply])
           .where('read_at <= ?', to_date)
           .order(read_at: :desc)
           .limit(1)
           .first
  end
end
