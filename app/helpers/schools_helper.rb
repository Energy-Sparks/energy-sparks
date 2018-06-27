module SchoolsHelper
  def meter_and_data?(school, meter_type)
    school.meters?(meter_type) && school.last_reading_date(meter_type).present?
  end

  def daily_usage_chart(supply, first_date, to_date, meter = nil, measurement = 'kwh')
    measurement, ytitle = sort_out_y_title_and_measurement(measurement)

    column_chart(
      compare_daily_usage_school_path(supply: supply, first_date: first_date, to_date: to_date, meter: meter, measurement: measurement),
      id: "chart",
      xtitle: 'Day of the week',
      ytitle: ytitle,
      height: '500px',
      colors: colours_for_supply(supply),
      library: {
         credits: { enabled: true },
          yAxis: {
              lineWidth: 1
          }
      }
    )
  end

  def sort_out_y_title_and_measurement(measurement)
    case measurement
    when 'kwh'
      ytitle = 'Energy (kWh)'
    when 'pounds'
      ytitle = 'Cost (£)'
      measurement = '£'
    when '£'
      ytitle = 'Cost (£)'
    when 'co2'
      ytitle = 'Carbon Dioxide emissions (kg)'
    else
      measurement = 'kwh'
      ytitle = 'Energy (kWh)'
    end
    [measurement, ytitle]
  end

  def compare_hourly_usage_chart(supply, first_date, to_date, meter = nil, measurement = 'kW')
    line_chart(compare_hourly_usage_school_path(supply: supply, first_date: first_date, to_date: to_date, meter: meter, measurement: measurement),
          id: "chart",
          xtitle: 'Time of day',
          ytitle: 'kW',
          height: '500px',
          colors: colours_for_supply(supply),
          library: {
            credits: { enabled: true },
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

  def kid_date(date)
    date.strftime('%A, %d %B %Y')
  end

  def kid_date_no_year(date)
    date.strftime('%A, %d %B')
  end

  def colours_for_supply(supply)
    supply == "electricity" ? %w(#3bc0f0 #232b49) : %w(#ffac21 #ff4500)
  end

  def meter_display_name(meter_no)
    return meter_no if meter_no == "all"
    meter = Meter.find_by_meter_no(meter_no)
    meter.present? ? meter.display_name : meter
  end

  def daily_usage_to_precision(school, supply, dates, meter, measurement, to_precision = 1)
    measurement_symbol = measurement.to_sym
    fuel_type = supply.to_sym

    precision = lambda { |reading| [reading[0], number_with_precision(convert_measurement(:kwh, measurement_symbol, fuel_type, reading[1]), precision: to_precision)] }

    school.daily_usage(supply: supply,
      dates: dates,
      date_format: '%A',
      meter: meter
    ).map(&precision)
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
    day.nil? ? '?' : "#{day[0].strftime('%A')} #{day[0].day.ordinalize} #{day[0].strftime('%B')} "
  end

  module BenchmarkMetrics
    ELECTRICITY_PRICE = 0.12
    GAS_PRICE = 0.03
    OIL_PRICE = 0.05
    PERCENT_ELECTRICITY_OUT_OF_HOURS_BENCHMARK = 0.3
    PERCENT_GAS_OUT_OF_HOURS_BENCHMARK = 0.3
    BENCHMARK_ELECTRICITY_USAGE_PER_PUPIL = 50_000.0 / 200.0
    BENCHMARK_ELECTRICITY_USAGE_PER_M2 = 50_000.0 / 1_200.0
    BENCHMARK_GAS_USAGE_PER_PUPIL = 115_000.0 / 200.0
    BENCHMARK_GAS_USAGE_PER_M2 = 115_000.0 / 1_200.0
  end

  def convert_measurement(from_unit, to_unit, fuel_type, from_value)
    from_scaling = scale_unit_from_kwh(from_unit, fuel_type)
    to_scaling = scale_unit_from_kwh(to_unit, fuel_type)
    val = from_value * to_scaling / from_scaling
    scale_num(val)
  end

  def scale_num(number)
    if number.nil? || number.nan?
      '' # specific case where no value specified
    elsif number < 50
      number.round(2).to_s
    elsif number < 1000
      number.round(0).to_s
    else
      number.round(0).to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
    end
  end

  # convert from kwh to a different unit
  # - fuel_type: :gas, :electricity is required for £ & CO2 conversion
  def scale_unit_from_kwh(unit, fuel_type)
    case unit
    when :kwh
      scale_to_kwh
    when :kw
      scale_to_kw
    when :co2 # https://www.gov.uk/government/publications/greenhouse-gas-reporting-conversion-factors-2018
      scale_to_co2(fuel_type)
    when :£
      scale_to_pound(fuel_type)
    when :library_books
      scale_unit_from_kwh(:£, fuel_type) / 5.0 # £5 per library book
    else
      raise "Error: unknown unit type #{unit}" unless unit.nil?
      raise 'Error: nil unit type'
    end
  end

  def scale_to_kwh
    1.0
  end

  def scale_to_kw
    2.0 # kWh in 30 mins, but perhap better to raise error
  end

  def scale_to_co2(fuel_type)
    case fuel_type
    when :electricity, :storage_heater
      0.283 # 283g/kWh UK Grid Intensity
    when :gas, :heat # TODO(PH,1Jun2018) - rationalise heat versus gas
      0.204 # 204g/kWh
    when :oil
      0.285 # 285g/kWh
    when :solar_pv
      0.040 # 40g/kWh - life cycle costs TODO(PH,14Jun2018) find reference to current UK official figures
    else
      raise "Error: CO2: unknown fuel type #{fuel_type}" unless fuel_type.nil?
      raise 'Error: CO2: nil fuel type'
    end
  end

  def scale_to_pound(fuel_type)
    case fuel_type
    when :electricity, :storage_heater
      BenchmarkMetrics::ELECTRICITY_PRICE # 12p/kWh long term average
    when :gas, :heat # TODO(PH,1Jun2018) - rationalise heat versus gas
      BenchmarkMetrics::GAS_PRICE # 3p/kWh long term average
    when :oil
      BenchmarkMetrics::OIL_PRICE # 5p/kWh long term average
    when :solar_pv
      -1 * scale_unit_from_kwh(:£, :electricity)
    else
      raise EnergySparksUnexpectedStateException.new("Error: £: unknown fuel type #{fuel_type}") unless fuel_type.nil?
      raise EnergySparksUnexpectedStateException.new('Error: £: nil fuel type')
    end
  end
end
