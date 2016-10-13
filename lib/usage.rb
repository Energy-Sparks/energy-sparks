module Usage
  # calculate daily usage for a range of dates
  def daily_usage(supply = nil, dates = [])
    # supply and dates arguments required
    return [] if supply.blank? || dates.blank?
    # get school's meters for this supply type
    meters = self.meters.where(meter_type: supply)
    return [] if meters.empty?
    daily_totals = []
    dates.each do |date|
      supply_total = nil
      meters.each do |meter|
        first = meter.meter_readings.where('read_at > ? AND read_at <= ?',
          date.beginning_of_day, date.end_of_day).order(read_at: :asc).limit(1).first
        last = meter.meter_readings.where('read_at > ? AND read_at <= ?',
          date.beginning_of_day, date.end_of_day).order(read_at: :desc).limit(1).first
        if first
          supply_total ||= 0
          supply_total += (last.value - first.value)
        end
      end
      daily_totals << supply_total
    end
    daily_totals
  end
end
