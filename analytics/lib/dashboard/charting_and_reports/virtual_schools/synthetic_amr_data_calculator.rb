# frozen_string_literal: true

# Generates the synthetic AMR data used to plot usage data for benchmark and exemplar schools
class SyntheticAMRDataCalculator # rubocop:todo Metrics/ClassLength
  class UnexpectedSchoolTypeException < StandardError; end

  def initialize(school)
    @school = school
    @school_type = school.school_type.to_sym
    @floor_area = @school.floor_area
    @pupils = @school.number_of_pupils
    return if %i[primary infant junior special middle secondary mixed_primary_and_secondary].include?(@school_type)

    raise UnexpectedSchoolTypeException, "Unknown school type #{@school_type}"
  end

  def benchmark_amr_data(meter:, benchmark_type: :benchmark)
    calculate_amr_data(meter: meter, benchmark_type: benchmark_type)
  end

  def self.remap_low_sample_holiday(holiday_type, date) # rubocop:todo Metrics/CyclomaticComplexity
    holiday_type = :easter if holiday_type == :mayday
    if Holidays::MAIN_HOLIDAY_TYPES.include?(holiday_type)
      holiday_type
    else
      # similar to Holidays.holiday_type but only returns MAIN_HOLIDAY_TYPES
      case date.month
      when 1, 12
        :xmas
      when 2
        :spring_half_term
      when 3, 4
        :easter
      when 5
        :summer_half_term
      when 6
        date.day > 24 ? :summer : :summer_half_term
      when 7, 8
        :summer
      when 9
        date.day < 15 ? :summer : :autumn_half_term
      when 10, 11
        :autumn_half_term
      end
    end
  end

  private

  # Calculates synthetic AMR data
  #
  # param Dashboard::Meter meter the meter whose AMR data will be basis for data
  # param Symbol benchmark_type the type of benchmark being produced, e.g. benchmark (well managed) or exemplar
  # param Integer pupils number of pupils in school
  # param Float floor_area floor area of school
  # param Boolean degreday_adjustment whether to adjust gas data based on degree days rather than floor area
  def calculate_amr_data(meter:, benchmark_type: :benchmark, degreeday_adjustment: true)
    interpolators = create_term_time_interpolators(benchmark_type, meter.fuel_type)
    now = DateTime.now
    scale_by = scaling_factor(meter, degreeday_adjustment:)
    benchmark_amr_data = AMRData.new(benchmark_type)

    (meter.amr_data.start_date..meter.amr_data.end_date).each do |date|
      avg_kwh_x48_for_day = avg_kwh_x48_for_day(date, benchmark_type, interpolators, meter.fuel_type)
      kwh_x48 = AMRData.fast_multiply_x48_x_scalar(avg_kwh_x48_for_day, scale_by)
      benchmark_amr_data.add(date, OneDayAMRReading.new(date, 'CAVG', nil, now, kwh_x48))
    end

    benchmark_amr_data
  end

  def scaling_factor(meter, degreeday_adjustment: true)
    if meter.fuel_type == :electricity
      @pupils
    elsif degreeday_adjustment
      degree_days_to_average_factor_reversed(meter.meter_collection,
                                             meter.amr_data.end_date)
    else
      @floor_area
    end
  end

  def degree_days_to_average_factor_reversed(school, end_date)
    end_date   = [end_date, school.temperatures.end_date].min
    start_date = [end_date - 365, school.temperatures.start_date].max

    return @floor_area if end_date - start_date < 360 # shouldn't happen as temperatures should be backdated a year

    avg_degree_days = BenchmarkMetrics::ANNUAL_AVERAGE_DEGREE_DAYS

    school_degree_days = school.temperatures.degree_days_in_date_range(start_date, end_date)

    # very crude for as really need to scale monthly degree days
    # versus precalculated national average for each month
    # school.aggregated_heat_meters.heating_model.heating_on?(date)

    # if a school is colder than average i.e. > school_degree_days increase its consumption from average

    @floor_area * school_degree_days / avg_degree_days
  end

  def avg_kwh_x48_for_day(date, benchmark_type, interpolators, fuel_type)
    day_type = @school.holidays.day_type(date)
    if day_type == :holiday
      holiday_type = @school.holidays.holiday(date).type
      holiday_type = self.class.remap_low_sample_holiday(holiday_type, date)
      average_school_data(fuel_type, benchmark_type)[:holiday][holiday_type]
    else
      days_readings_x48(date.yday, interpolators[day_type])
    end
  end

  # Create interpolators for calculating schoolday and weekend half-hourly data
  # The interpolators are each responsible for creating values for single half-hour period.
  def create_term_time_interpolators(benchmark_type, fuel_type)
    raw_data = average_school_data(fuel_type, benchmark_type)
    %i[schoolday weekend].to_h do |daytype|
      extended_months_data = configure_14_months(raw_data[daytype])
      [
        daytype,
        setup_intraday_interpolators_x48_half_hours_x14_months(extended_months_data)
      ]
    end
  end

  def average_school_data(fuel_type, benchmark_type)
    Schools::AverageSchoolData.raw_data[fuel_type][benchmark_type][average_school_type_key]
  end

  def average_school_type_key
    return :primary if %i[infant junior].include?(@school_type)
    return :secondary if %i[mixed_primary_and_secondary middle].include?(@school_type)

    @school_type
  end

  def days_readings_x48(day_of_year, interpolators_x48)
    interpolators_x48.map do |interpolator|
      interpolator.at(day_of_year)
    end
  end

  # for interpolation purposes add a month on and start and end of a year so the data wraps around for interpolation,
  # rather than the interpolation being truncated
  #
  # 2026-07 used to substitute August with July due to large number of Scottish schools with high usage skewing figures
  # but now have few schools in Scotland.
  def configure_14_months(months_data)
    months_data[0]  = months_data[12]
    months_data[13] = months_data[0]
    months_data.sort.to_h
  end

  # returns 48 (half hour) interpolators - each covering 14 months
  def setup_intraday_interpolators_x48_half_hours_x14_months(extended_months_data)
    days_since_start_of_year = [-15, 15, 45, 75, 105, 135, 165, 195, 225, 255, 285, 315, 345, 380]

    (0..47).map do |half_hour|
      # produce an array of 14 values, one value per month
      kwh_per_hh_per_pupil = extended_months_data.keys.map do |month|
        extended_months_data[month][half_hour]
      end
      # Converts the month number hash into one based on days since start of year, to can interpolate on day number
      Interpolate::Points.new(days_since_start_of_year.zip(kwh_per_hh_per_pupil).to_h)
    end
  end
end
