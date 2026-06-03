class Temperatures < HalfHourlyData
  include Logging

  class MissingTemperatureDataError < StandardError; end

  FROSTPROTECTIONTEMPERATURE = 4.0
  def initialize(type)
    super(type)
    @cached_min_max = {}
    @cached_average_on_date = {}
  end

  def get_temperature(date, half_hour_index)
    logger.error 'Warning: deprecated interface get_temperature'
    logger.error Thread.current.backtrace.join("\n")
    temperature(date, half_hour_index)
  end

  def temperature(date, half_hour_index)
    data(date, half_hour_index)
  end

  def average_temperature(date)
    average(date)
  end

  def average_temperature_for_time_of_year(time_of_year:, days_either_side: 0)
    time_of_year = TimeOfYear.new(2, 28) if time_of_year.month == 2 && time_of_year.day == 29

    avg_temperatures = []

    date = end_date

    while date >= start_date
      time_of_year_date_this_year = Date.new(date.year, time_of_year.month, time_of_year.day)

      if time_of_year_date_this_year.between?(start_date + days_either_side, end_date - days_either_side)
        avg_temperatures += (-days_either_side..days_either_side).map { |offset| average_temperature(time_of_year_date_this_year + offset) }
      end
      date = Date.new(date.year - 1, date.month, date.day)
    end

    if avg_temperatures.length.zero?
      error_message = "No data for time of year #{time_of_year}, have temperatures between #{start_date} and #{end_date}"
      logger.info error_message
      raise MissingTemperatureDataError, error_message
    else
      avg_temperatures.sum / avg_temperatures.length
    end
  end

  def average_temperature_in_date_range(start_date, end_date)
    average_in_date_range(start_date, end_date)
  end

  def average_temperature_in_time_range(date, start_halfhour_index, end_halfhour_index)
    one_days_data_x48(date)[start_halfhour_index..end_halfhour_index].sum / (end_halfhour_index - start_halfhour_index + 1)
  end

  def temperature_range(start_date, end_date)
    return @cached_min_max[start_date..end_date] if @cached_min_max.key?(start_date..end_date)
    min_temp = 100.0
    max_temp = -100.0
    (start_date..end_date).each do |date|
      (0..47).each do |i|
        temp = temperature(date, i)
        min_temp = temp < min_temp ? temp : min_temp
        max_temp = temp > max_temp ? temp : max_temp
      end
    end
    @cached_min_max[start_date..end_date] = [min_temp, max_temp]
    [min_temp, max_temp]
  end

  def halfhours_below_temperature(start_date, end_date, temperature_level, day_of_week = nil, holidays = nil, is_holiday = nil)
    halfhour_count = 0
    (start_date..end_date).each do |date|
      next if !is_holiday.nil? && !holidays.nil? && holidays.holiday?(date) == is_holiday
      next if !day_of_week.nil? && day_of_week != date.wday
      (0..47).each do |i|
        halfhour_count += 1 if temperature(date, i) <= temperature_level
      end
    end
    halfhour_count
  end

  # find days with longest number of half hours below 4C, deal with duplicate stats
  def frost_days(start_date, end_date, day_of_week = nil,  holidays = nil, is_holiday = nil)
    frostdates_by_num_halfhours = Array.new(49){Array.new} # zero half hours, plus 48, up to all day = 48, so 49 buckets
    end_date.downto(start_date) do |date| # reverse order so recent more prominent
      halfhours = halfhours_below_temperature(date, date, FROSTPROTECTIONTEMPERATURE, day_of_week, holidays, is_holiday)
      frostdates_by_num_halfhours[halfhours].push(date) if halfhours > 0
    end
    frost_dates = []
    48.downto(0) do |halfhours|
      frostdates_by_num_halfhours[halfhours].each do |date|
        frost_dates.push(date)
      end
    end
    frost_dates
  end

  # find days with highest idurnal ranges, for thermostatic analysis
  def largest_diurnal_ranges(start_date, end_date, winter = false,  weekend = nil, holidays = nil, is_holiday = nil)
    # get a list of diurnal ranges
    diurnal_ranges = {} # diurnal temperature date = [list of dates with that range] i.e. deal with duplicates
    end_date.downto(start_date) do |date| # reverse order so recent more prominent
      next if !weekend.nil? && weekend != DateTimeHelper.weekend?(date)
      next if winter && ![11, 12, 1, 2, 3].include?(date.month)
      next if !is_holiday.nil? && !holidays.nil? && holidays.holiday?(date) != is_holiday
      min_temp, max_temp = temperature_range(date, date)
      diurnal_range = max_temp - min_temp
      diurnal_ranges[diurnal_range] = Array.new unless diurnal_ranges.key?(diurnal_range)
      diurnal_ranges[diurnal_range].push(date)
    end

    # flatten list and return dates in order of biggest diurnal ranges
    descending_diurnal_ranges_dates = []
    descending_diurnal_ranges = diurnal_ranges.keys.sort.reverse
    descending_diurnal_ranges.each do |diurnal_range|
      descending_diurnal_ranges_dates.concat(diurnal_ranges[diurnal_range])
    end
    descending_diurnal_ranges_dates
  end

  def temperature_datetime(datetime)
    date, half_hour_index = DateTimeHelper.date_and_half_hour_index(datetime)
    temperature(date, half_hour_index)
  end

  def degreesday_range(start_date, end_date, base_temp)
    min_temp, max_temp = temperature_range(start_date, end_date)
    degreeday_min = max_temp > base_temp ? 0.0 : (max_temp - base_temp)
    degreeday_max = min_temp > base_temp ? 0.0 : (min_temp - base_temp)
    [degreeday_min, degreeday_max]
  end

  def degree_hours(date, base_temp)
    dh = 0.0
    (0..47).each do |halfhour_index|
      dh += degree_hour(date, halfhour_index, base_temp)
    end
    dh / 48
  end

  def degree_hour(date, halfhour_index, base_temp)
    dh = 0.0
    t = data(date, halfhour_index)
    dh = base_temp - t if t <= base_temp
    dh
  end

  def degree_days(date, base_temp = 15.5)
    # return modified_degree_days(date, base_temp)
    avg_temperature = average_temperature(date)
    avg_temperature <= base_temp ? (base_temp - avg_temperature) : 0.0
  end

  def degree_days_this_year(asof_date = nil)
    asof_date = end_date if asof_date.nil?
    # computationally intensive so cache result
    (@years_degree_days ||= {})[asof_date] ||= degree_days_in_date_range(asof_date - 364, asof_date, 15.5)
  end

  def degree_days_in_date_range(start_date, end_date, base_temp = 15.5)
    (start_date..end_date).to_a.map { |date| degree_days(date, base_temp) }.sum
  end

  def modified_degree_days(date, base_temp)
    frost_degree_hours = 0.0
    (0..47).each do |i|
      if i < 2 * 6 || i > 2 * 19
        frost_degree_hours += (20 - temp) / 2.0 if temperature(date, i) < 4
      end
    end

    avg_temperature = average_temperature(date)
    if avg_temperature <= base_temp
      if frost_degree_hours > 0
        before = (base_temp - avg_temperature)
        after = (base_temp - avg_temperature) + frost_degree_hours / 8.0
        logger.debug "mod deg days #{date} : #{before} becomes #{after}"
      end
      return (base_temp - avg_temperature) + 0.0 * frost_degree_hours / 8.0
    else
      return 0.0
    end
  end

  # end_date inclusive
  def degrees_days_average_in_range(base_temp, start_date, end_date)
    d_days = 0.0
    (start_date..end_date).each do |date|
      d_days += degree_days(date, base_temp)
    end
    d_days / (end_date - start_date + 1)
  end
end
