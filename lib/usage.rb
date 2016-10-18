module Usage
  # calculate daily usage for a range of dates
  def daily_usage(supply = nil, dates = [])
    # supply and dates arguments required
    return [] if supply.blank? || dates.blank?
    self.meter_readings
        .where('meters.meter_type = ?', Meter.meter_types[supply])
        .where('read_at >= ? AND read_at <= ?',
                dates.first.beginning_of_day,
                dates.last.end_of_day
              )
        .group("read_at::date")
        .order("read_at::date")
        .sum(:value).to_a
  end
end
