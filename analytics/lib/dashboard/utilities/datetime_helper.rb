# Date and timer help functions
module DateTimeHelper
  def self.weekend?(date)
    date.saturday? || date.sunday?
  end

  # returns the next weekday 0 = Sunday.....6 = Saturday for date, if date = weekday then return date
  def self.next_weekday(date, wday)
    days_to_wday = date.wday - wday
    if date.wday < wday
      date = date + (wday - date.wday)
    elsif date.wday > wday
      date = date + (7 - (date.wday - wday))
    else
      date
    end
  end

  def self.daytype(date, holidays)
    return :holiday if holidays.holiday?(date)
    weekend?(date) ? :weekend : :schoolday
  end

  def self.weekend?(date)
    date.saturday? || date.sunday?
  end

  def self.days_in_month(date)
    Date.new(date.year, date.month, -1).day
  end

  def self.first_day_of_month(date)
    Date.new(date.year, date.month, 1)
  end

  def self.last_day_of_month(date)
    if date.month == 12
      Date.new(date.year + 1, 1, 1) - 1
    else
      Date.new(date.year, date.month + 1, 1) - 1
    end
  end

  def self.days_in_quarter(date)
    days = 0
    quarter = ((date.month - 1) / 3).to_i
    [1..3, 4..6, 7..9, 10..12][quarter].each do |month|
      days += days_in_month(Date.new(date.year, month, 1))
    end
    days
  end

  def self.datetime(date, halfhour_index)
    hour = (halfhour_index / 2).round
    minute = halfhour_index % 2 == 1 ? 30 : 0

    # Time is too slow on Windows, order of magnitude slower than DateTime
    DateTime.new(date.year, date.month, date.day, hour, minute, 0)
  end

  def self.time_of_day(halfhour_index)
    hour = (halfhour_index / 2).round
    minute = halfhour_index % 2 == 1 ? 30 : 0
    TimeOfDay.new(hour, minute)
  end

  def self.date_and_half_hour_index(datetime)
    date = Date.new(datetime.year, datetime.month, datetime.day)
    index = datetime.hour * 2 + (datetime.min >= 30 ? 1 : 0)
    [date, index]
  end

  def self.half_hour_index(datetime)
    _date, index = date_and_half_hour_index(datetime)
    index
  end

  def self.time_to_date_and_half_hour_index(time)
    date = Date.new(time.year, time.month, time.day)
    index = time.hour * 2 + (time.min % 30)
    [date, index]
  end

  def self.covid_lockdown_date?(date)
    date.between?(Date.new(2020, 3, 22), Date.new(2020, 9, 3))
  end

  # takes an array of time of day ranges and returns a weighted vector for
  # the standard 0..47 halfhourly buckets
  # e.g. 00:15..01:45 would return [0.5, 1.0, 1.0, 0.5, 0.0......0.0]
  def self.weighted_x48_vector_multiple_ranges(time_of_day_ranges, weight = 1.0)
    result = nil
    time_of_day_ranges.each do |time_of_day_range|
      weighted_x48 = weighted_x48_vector_single_range(time_of_day_range, weight)
      result = result.nil? ? weighted_x48 : AMRData.fast_add_x48_x_x48(weighted_x48, result)
    end
    result
  end

  # For this method the time_of_day_range specified here is exclusive, i.e.
  # the end of the range is not part of the weighted period
  #
  # e.g. a range end of 23:30 will not include the final half-hourly period of a day
  #
  # To specify a full day, the end range must be 24:00.
  #
  # Unlike weighted_x48_vector_fast_inclusive the method does not support overnight
  # ranges, e.g. a range of 23:00-02.00, will just produce invalid output.
  #
  # return a vector for a single time range (as per weighted_x48_vector_multiple_ranges)
  # performance could be improved, currently takes 0.000007 seconds or 150,000 per second or 15ms for an average meter
  def self.weighted_x48_vector_single_range(time_of_day_range, weight = 1.0)
    start_time = time_of_day_range.first
    end_time = time_of_day_range.last
    start_halfhour_index, start_excess_minutes_percent = start_time.to_halfhour_index_with_fraction
    end_halfhour_index, end_excess_minutes_percent = end_time.to_halfhour_index_with_fraction
    result = []
    (0..47).each do |halfhour_index|
      value = 0.0
      if halfhour_index == start_halfhour_index
        value =  start_excess_minutes_percent > 0.0 ? (1.0 - start_excess_minutes_percent) : 1.0
      elsif halfhour_index > start_halfhour_index && halfhour_index < end_halfhour_index
        value = 1.0
      elsif halfhour_index == end_halfhour_index
        value = end_excess_minutes_percent > 0.0 ? end_excess_minutes_percent : 0.0
      end
      result.push(value * weight)
    end
    result
  end


  # For this method the time_of_day_range specified here is inclusive, i.e.
  # the end of the range is not part of the weighted period
  #
  # e.g. a range end of 23:30 will include the final half-hourly period of a day.
  # That should be used to specify a full day.
  #
  # FIXME:
  # Unlike `weighted_x48_vector_single_range` an end range of 24:00 will produce
  # invalid results, as the array with have 49 elements.
  #
  # Also unlike `weighted_x48_vector_single_range` overnight ranges are supported
  # So a range of 23:00..02:00 is valid and will produce the expected output.
  #
  # This also means an end range of 00:00 will add a weight to the first half-hourly
  # period of the day. Care needs to be taken here as this might not be what was
  # expected from a night time range of: 22:00..00:00.
  def self.weighted_x48_vector_fast_inclusive(time_of_day_range, weight)
    arr_x48 = Array.new(48, 0.0)
    hh_index_start  = time_of_day_range.first.to_halfhour_index
    hh_index_end    = time_of_day_range.last.to_halfhour_index
    if hh_index_start <= hh_index_end
      set_weights_in_date_range(arr_x48, hh_index_start, hh_index_end, weight)
    else # crosses midnight e.g. 22:30 to 02:00, translates to 22:30 to 23:30, 00:00 to 02:00
      set_weights_in_date_range(arr_x48, hh_index_start, 47, weight)
      set_weights_in_date_range(arr_x48, 0, hh_index_end, weight)
    end
    arr_x48
  end

  private_class_method def self.set_weights_in_date_range(arr_x48, hh_index_start, hh_index_end, weight)
    (hh_index_start..hh_index_end).each do |hh_index|
      arr_x48[hh_index] = weight
    end
  end
end
