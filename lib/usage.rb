# Library of function to calculate energy usage for a school
# This library is included in the School model
module Usage
  # daily_usage: get daily usage across all meters for a given
  # supply for a range of dates
  def daily_usage(supply: nil, dates: nil, date_format: nil, meter: nil)
    return nil unless dates
    datetime_range = (dates.first.beginning_of_day..dates.last.end_of_day)
    self.meter_readings
        .where(conditional_supply(supply))
        .where(conditional_meter(meter))
        .group_by_day(:read_at, range: datetime_range, format: date_format)
        .sum(:value)
        .to_a
    #self.amr_readings.where(date: datetime_range).map { |r| [ r.date, r.kwh_data_x48.sum] }
  end

  def hourly_usage_for_date(supply: nil, date: nil, meter: nil, scale: :kwh)
    datetime_range = (date.beginning_of_day..date.end_of_day)
    sum = scale == :kwh ? "value" : "2 * value"
    self.meter_readings
        .where(conditional_supply(supply))
        .where(conditional_meter(meter))
        .group_by_minute(:read_at,
            range: datetime_range,
            format: '%H:%M',
            series: false
        )
        .sum(sum)
        .to_a
  end

  # compare weekday/weekend hourly usage
  # hourly_usage: get average reading at the same time
  # across all meters for a given supply for a range of dates
  def hourly_usage(supply: nil, dates: nil, meter: nil)
    #minutes = ["00:00", "00:30", "01:00", "01:30", "02:00", "02:30", "03:00", "03:30", "04:00", "04:30", "05:00", "05:30", "06:00", "06:30", "07:00", "07:30", "08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30", "20:00", "20:30", "21:00", "21:30", "22:00", "22:30", "23:00", "23:30"]
    return nil unless dates
    datetime_range = (dates.first.beginning_of_day..dates.last.end_of_day)
    self.meter_readings
        .where(conditional_supply(supply))
        .where(conditional_meter(meter))
        .group_by_minute(
          :read_at,
          range: datetime_range,
          format: '%H:%M',
          series: false
        )
        .average(:value)
        .to_a
   #     @school.amr_readings.where(date: Date.today - 1.month).first.kwh_data_x48.each_with_index.map { |a, index| [minutes[index], a] }
  end

  # Get date of the last reading up to the given date
  # We take the start of the day because we're always interested in a full day
  # of readings. Want to avoid showing updates when we might be loading data.
  def last_reading_date(supply, to_date = Date.current)
    self.meter_readings
        .where(conditional_supply(supply))
        .where('read_at <= ?', to_date.beginning_of_day)
        .order(read_at: :desc)
        .limit(1)
        .first
        .try(:[], 'read_at')
        .try(:to_date)
    # self.amr_readings.where('date <= ?', Date.current).maximum(:date)
  end

  def earliest_reading_date(supply)
    self.meter_readings
        .where(conditional_supply(supply))
        .order(read_at: :asc)
        .limit(1)
        .first
        .try(:[], 'read_at')
        .try(:to_date)
    # irb(main):024:0> @school.amr_readings.where('date <= ?', Date.current).minimum(:date)
  end

  def last_n_days_with_readings(supply, window = 7, to_date = Date.current)
    latest = self.last_reading_date(supply, to_date)
    latest.nil? ? nil : latest - window.days..latest
  end

  # last_friday_with_readings: get date of the last friday which has readings
  def last_friday_with_readings(supply = nil)
    self.meter_readings
        .where(conditional_supply(supply))
        .where('EXTRACT(DOW FROM read_at) = ?', 5)
        .order(read_at: :desc)
        .limit(1)
        .first
        .try(:[], 'read_at')
        .try(:to_date)
    #@school.amr_readings.where("extract(dow from date) = ?", 5).maximum(:date)
  end

  # return the date range of the last full week with readings
  def last_full_week(supply)
    friday = self.last_friday_with_readings(supply)
    friday.nil? ? nil : friday - 4.days..friday
  end

  # return day of the week with the most usage
  # for the last seven days of readings
  def day_most_usage(supply)
    usage = daily_usage(supply: supply, dates: last_n_days_with_readings(supply))
    return nil unless usage
    # rubocop:disable Performance/UnneededSort
    usage.sort { |a, b| a[1] <=> b[1] }.last
    # rubocop:enable  Performance/UnneededSort
  end

  # return date range for week in which this date falls
  def self.this_week(date = Date.current)
    previous_sat = date - ((date.wday - 6) % 7) # Sun = 0, Sat = 6
    previous_sat..previous_sat + 6.days # week runs from Sat to Fri
  end

private

  def conditional_supply(supply)
    { meters: { meter_type: Meter.meter_types[supply] } } if supply
  end

  def conditional_meter(meter)
    { meters: { meter_no: meter } } if meter.present? && meter != "all"
  end
end
