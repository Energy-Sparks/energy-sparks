module SchoolsHelper

  def meter_and_data?(school, meter_type)
    school.meters?(meter_type) && school.last_reading_date(meter_type).present?
  end

  def daily_usage_chart(supply, first_date, to_date, meter = nil, measurement = 'kwh')
    measurement = 'kwh' if measurement.nil?
    measurement = 'kwh' if measurement == 'kWh'
    measurement = '£' if measurement == 'pounds'

    column_chart(
      compare_daily_usage_school_path(supply: supply, first_date: first_date, to_date: to_date, meter: meter, measurement: measurement),
      id: "chart",
      xtitle: 'Date',
      ytitle: measurement,
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

  def daily_usage_to_precision(school, supply, dates, meter, to_precision = 1, measurement)
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

  def convert_measurement(from_unit, to_unit, fuel_type, from_value, round = true)
    from_scaling = scale_unit_from_kwh(from_unit, fuel_type)
    to_scaling = scale_unit_from_kwh(to_unit, fuel_type)
    val = from_value * to_scaling / from_scaling
    round ? scale_num(val) : val
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

  # def self.convert_multiple(from_unit, to_units, fuel_type, from_value, round = true)
  #   converted_values = []
  #   to_units.each do |to_unit|
  #     converted_values.push(convert(from_unit, to_unit, fuel_type, from_value))
  #   end
  #   converted_values
  # end

  # convert from kwh to a different unit
  # - fuel_type: :gas, :electricity is required for £ & CO2 conversion
  def scale_unit_from_kwh(unit, fuel_type)
    unit_scale = nil
    case unit
    when :kwh
      unit_scale = 1.0
    when :kw
      unit_scale = 2.0 # kWh in 30 mins, but perhap better to raise error
    when :co2 # https://www.gov.uk/government/publications/greenhouse-gas-reporting-conversion-factors-2018
      case fuel_type
      when :electricity, :storage_heater
        unit_scale = 0.283 # 283g/kWh UK Grid Intensity
      when :gas, :heat # TODO(PH,1Jun2018) - rationalise heat versus gas
        unit_scale = 0.204 # 204g/kWh
      when :oil
        unit_scale = 0.285 # 285g/kWh
      when :solar_pv
        unit_scale = 0.040 # 40g/kWh - life cycle costs TODO(PH,14Jun2018) find reference to current UK official figures
      else
        raise "Error: CO2: unknown fuel type #{fuel_type}" unless fuel_type.nil?
        raise 'Error: CO2: nil fuel type'
      end
    when :£
      case fuel_type
      when :electricity, :storage_heater
        unit_scale = BenchmarkMetrics::ELECTRICITY_PRICE # 12p/kWh long term average
      when :gas, :heat # TODO(PH,1Jun2018) - rationalise heat versus gas
        unit_scale = BenchmarkMetrics::GAS_PRICE # 3p/kWh long term average
      when :oil
        unit_scale = BenchmarkMetrics::OIL_PRICE # 5p/kWh long term average
      when :solar_pv
        unit_scale = -1 * scale_unit_from_kwh(:£, :electricity)
      else
        raise EnergySparksUnexpectedStateException.new("Error: £: unknown fuel type #{fuel_type}") unless fuel_type.nil?
        raise EnergySparksUnexpectedStateException.new('Error: £: nil fuel type')
      end
    when :library_books
      unit_scale = scale_unit_from_kwh(:£, fuel_type) / 5.0 # £5 per library book
    else
      raise "Error: unknown unit type #{unit}" unless unit.nil?
      raise 'Error: nil unit type'
    end
    unit_scale
  end
end
