class SolarIrradiance < HalfHourlyData
  def initialize(type, solar_pv_data: nil)
    super(type)
    @cache_daylight_irradiance = {}
    create_from_halfhourly_data(solar_pv_data) unless solar_pv_data.nil?
  end

  def solar_irradiance(date, half_hour_index)
    data(date, half_hour_index) * scaling_factor(date)
  end

  def average_days_irradiance_above_threshold(date, threshold)
    total = 0.0
    count = 0
    (0..48).each do |halfhour_index|
      irr = irradiance(date, halfhour_index)
      if irr > threshold
        total += irr
        count += 1
      end
    end
    total / count
  end

  def average_days_irradiance_between_times(date, halfhour_index1, halfhour_index2)
    total = 0.0
    (halfhour_index1..halfhour_index2).each do |halfhour_index|
      total += irradiance(date, halfhour_index)
      irr = irradiance(date, halfhour_index)
    end
    total / (halfhour_index2 - halfhour_index1 + 1)
  end

  def average_daytime_irradiance_in_date_range(date1, date2)
    total = 0.0 # do calc as scalar rather than array for performance
    count = 1
    (date1..date2).each do |date|
      total += average_irradiance_during_daylight(date)
      count += 1
    end
    total / count
  end

  def average_irradiance_during_daylight(date)
    return @cache_daylight_irradiance[date] if @cache_daylight_irradiance.key?(date)
    daylight_readings = one_days_data_x48(date).select { |irradiance| irradiance > 0.0 }
    avg = daylight_readings.empty? ? 0.0 : (daylight_readings.sum / daylight_readings.length)
    @cache_daylight_irradiance[date] = avg * scaling_factor(date)
  end

  def irradiance(date, half_hour_index)
    solar_irradiance(date, half_hour_index)
  end

  protected def scaling_factor(date)
    1.0
  end
end

class SolarIrradianceLoader < HalfHourlyLoader
  def initialize(csv_file, irradiance)
    super(csv_file, 0, 1, 0, irradiance)
  end
end
