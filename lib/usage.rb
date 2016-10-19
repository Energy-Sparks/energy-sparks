# Library of function to calculate energy usage for a school
# This library is included in the School model
module Usage
  # daily_usage: get daily usage across all meters for a given
  # supply for a range of dates
  def daily_usage(supply = nil, dates = [], date_format = nil)
    datetime_range = (dates.first.beginning_of_day..dates.last.end_of_day)
    self.meter_readings
        .where('meters.meter_type = ?', Meter.meter_types[supply])
        .group_by_day(:read_at, range: datetime_range, format: date_format)
        .sum(:value)
        .to_a
  end

  # last_reading: get date of the last reading on or before the given date
  def last_reading_date(supply, to_date)
    self.meter_readings
        .where('meters.meter_type = ?', Meter.meter_types[supply])
        .where('read_at <= ?', to_date.end_of_day)
        .order(read_at: :desc)
        .limit(1)
        .first
        .try(:[], 'read_at')
        .try(:to_date)
  end

  # last_friday_with_readings: get date of the last friday which has readings
  def last_friday_with_readings(supply = nil)
    self.meter_readings
        .where('meters.meter_type = ?', Meter.meter_types[supply])
        .where('EXTRACT(DOW FROM read_at) = ?', 5)
        .order(read_at: :desc)
        .limit(1)
        .first
        .try(:[], 'read_at')
        .try(:to_date)
  end
end
