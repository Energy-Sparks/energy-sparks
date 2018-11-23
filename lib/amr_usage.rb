# Library of function to calculate energy usage for a school
# This library is included in the School model
module AmrUsage
  MINUTES = ["00:30", "01:00", "01:30", "02:00", "02:30", "03:00", "03:30", "04:00", "04:30", "05:00", "05:30", "06:00", "06:30", "07:00", "07:30", "08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30", "20:00", "20:30", "21:00", "21:30", "22:00", "22:30", "23:00", "23:30", "24:00"].freeze
  # daily_usage: get daily usage across all meters for a given
  # supply for a range of dates
  def daily_usage(supply: nil, dates: nil, date_format: nil, meter: nil)
    return nil unless dates
    datetime_range = (dates.first.beginning_of_day..dates.last.end_of_day)

    # TODO this is a bit messy
    result_array = readings_with_selected_meters(supply, meter)
                    .where(reading_date: datetime_range)
                    .order(:reading_date)
                    .group_by(&:reading_date)
                    .map { |reading_date, amr_readings| [reading_date, amr_readings.sum(&:one_day_kwh).to_f] }

    fill_in_blank_dates(dates, result_array, date_format)
  end

  def fill_in_blank_dates(dates, result_array, date_format)
    # TODO this ensures empties are populated with 0.0
    (dates.first..dates.last).map do |date|
      result_for_date = result_array.select { |record| record[0] == date}.first
      if result_for_date.nil?
        [formatted_date(date, date_format), 0.0]
      else
        [formatted_date(date, date_format), result_for_date[1]]
      end
    end
  end

  def formatted_date(date, date_format = nil)
    date_format ? date.strftime(date_format) : date
  end

  def hourly_usage_for_date(supply: nil, date: nil, meter: nil, scale: :kwh)
    multiplier = scale == :kwh ? 1 : 2

    grouped_readings = readings_with_selected_meters(supply, meter).where(reading_date: date.all_day)
    grouped_readings.pluck(:kwh_data_x48).transpose.map(&:sum).each_with_index.map { |consumption, index| [MINUTES[index], (consumption.to_f * multiplier)] }
  end

  # Get date of the last reading up to the given date
  # We take the start of the day because we're always interested in a full day
  # of readings. Want to avoid showing updates when we might be loading data.
  def last_reading_date(supply, to_date = Date.current)
    readings_with_selected_meters(supply, nil).where('reading_date < ?', to_date).maximum(:reading_date)
  end

  def earliest_reading_date(supply)
    readings_with_selected_meters(supply, nil).minimum(:reading_date)
  end

  def last_n_days_with_readings(supply, window = 7, to_date = Date.current)
    latest = self.last_reading_date(supply, to_date)
    latest.nil? ? nil : latest - window.days..latest
  end

  # last_friday_with_readings: get date of the last friday which has readings
  def last_friday_with_readings(supply = nil)
    readings_with_selected_meters(supply, nil).where("extract(dow from reading_date) = ?", 5).maximum(:reading_date)
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

  def readings_with_selected_meters(supply, meter)
    self.amr_validated_readings.where(conditional_supply(supply)).where(conditional_meter(meter))
  end

  def conditional_supply(supply)
    { meters: { meter_type: Meter.meter_types[supply] } } if supply
  end

  def conditional_meter(meter)
    { meters: { meter_no: meter } } if meter.present? && meter != "all"
  end
end
