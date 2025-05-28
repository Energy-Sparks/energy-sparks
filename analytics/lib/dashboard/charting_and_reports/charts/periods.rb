# the timescale parameter comes from the 'chart_configuration' and helps define the
# arrangement or grouping of dates along the x-axis
# the parameter is heavingly overloaded, it can deal with a variety of values:
# :academic_year
# :year             - implies the current year to date i.e. using the lastest data
# :week
# and then these parameters are then overloaded as either hashes or arrays, for example
# {:week => Date.new(2018, 6, 1)}              # calculate a chart for a week ending 1Jun2018
# [{:week => 0}, {:week => -1}, {:week => -2}] # compare the last 3 weeks data - in the case of an array this class is called once for each element
#
class PeriodsBase
  def initialize(chart_config, meter_collection, first_meter_date, last_meter_date, type)
    @chart_config = chart_config
    @timescale = chart_config[:timescale]
    @override_meter_end_date = chart_config.key?(:calendar_picker_allow_up_to_1_week_past_last_meter_date)
    @minimum_days_data_override = chart_config[:minimum_days_data_override]
    @meter_collection = meter_collection
    @first_meter_date = first_meter_date
    @last_meter_date = last_meter_date
    @type = type
  end

  def periods
    all_periods = calculate_periods
    all_periods.each do |period|
      check_period_in_range(period) unless period.nil?
    end
    all_periods
  end

  def self.period_factory(chart_config, meter_collection, first_meter_date, last_meter_date)
    classes = {
      year:           YearPeriods,
      up_to_a_year:   UpToAYearPeriods,
      academicyear:   Periods::AcademicYears,
      activationyear: ActivationYearPeriods,
      month:          MonthPeriods,
      holiday:        HolidayPeriods,          # offset count starts with previous holiday
      includeholiday: InclusiveHolidayPeriods, # offset count starts with current holiday if in one
      week:           WeekPeriods,
      workweek:       WorkWeekPeriods,
      schoolweek:     SchoolWeekPeriods,
      day:            DayPeriods,
      schoolday:      SchoolDayPeriods,
      weekendday:     WeekendDayPeriods,
      frostday:       FrostDayPeriods,
      frostday_3:     FrostDay3Periods,
      diurnal:        DiurnalPeriods,
      optimum_start:  OptimumStartPeriods,
      daterange:      DateRangePeriods,
      hotwater:       HotWaterPeriod,
      none:           NoPeriod,
      twelve_months:  Periods::UpToTwelveMonths,
      fixed_academic_year: Periods::FixedAcademicYear
    }

    timescale_type = timescale_from_chart_config(chart_config)

    if classes.key?(timescale_type)
      classes[timescale_type].new(chart_config, meter_collection, first_meter_date, last_meter_date, timescale_type)
    else
      raise EnergySparksBadChartSpecification, "Unexpected chart timescale type #{@timescale.class.name}"
    end
  end

  # given a timescale e.g. {year: -4} return its start and end dates
  def self.period_dates(timescale, meter_collection, first_meter_date, last_meter_date)
    period_calc = PeriodsBase.period_factory({timescale: timescale}, meter_collection, first_meter_date, last_meter_date)
    period = period_calc.periods[0]
    period_calc.periods.compact.empty? ? nil : [period.start_date, period.end_date]
  end

  private def type_name; @type.to_s.humanize end

  # slightly messy switch to deal with legacy grammar of chart config timescale
  private_class_method def self.timescale_from_chart_config(chart_config)
    return chart_config[:timescale] if chart_config.key?(:timescale) && chart_config[:timescale].is_a?(Symbol)
    return chart_config[:timescale].keys[0] if chart_config.key?(:timescale) && chart_config[:timescale].is_a?(Hash)
    return chart_config[:x_axis] if [:year, :academicyear].include?(chart_config[:x_axis])
    return :hotwater if chart_config[:series_breakdown] == :hotwater
    :none
  end

  protected def period_list(_period_start, _period_end)
    raise EnergySparksAbstractBaseClass, "Unimplemented period_list method for class #{self.class.name}"
  end

  protected def check_out_of_range(date)
    raise EnergySparksNotEnoughDataException, "Error: date request for data out of range start date #{date} before first meter data #{@first_meter_date}" if date < @first_meter_date
    raise EnergySparksNotEnoughDataException, "Error: date request for data out of range end date #{date} before last meter data #{@last_meter_date}" if past_end_date(date)
  end

  protected def past_end_date(date)
    last_meter_date = @override_meter_end_date ? roll_date_to_next_saturday(@last_meter_date) : @last_meter_date
    date > last_meter_date
  end

  private def roll_date_to_next_saturday(date)
    date + (6 - date.wday)
  end

  protected def check_period_in_range(period)
    check_out_of_range(period.start_date)
    check_out_of_range(period.end_date)
  end

  protected def check_offset(offset)
    raise EnergySparksBadChartSpecification, "Error: expecting zero or negative number for #{self.class.name} specification" if offset > 0
  end

  protected def enough_data_for_override
    return false if @minimum_days_data_override.nil?
    (@last_meter_date - @first_meter_date + 1) >= @minimum_days_data_override
  end

  protected def check_or_create_minimum_period(periods)
    return periods unless periods.empty?
    if enough_data_for_override
      [SchoolDatePeriod.new(:less_data_than_ideal, 'limited data chart', @first_meter_date, @last_meter_date)]
    else
      periods
    end
  end

  private def calculate_periods
    if @timescale.nil? # @timescale.is_a?(Symbol) # e.g. x_axis: :year
      period_list # required for backward compatibility with aggregator, no timescale set, so assume full range
    elsif @timescale.is_a?(Symbol)
      [calculate_period_from_offset(0)]
    elsif @timescale.is_a?(Hash)
      _hash_key, hash_value = @timescale.first
      if hash_value.is_a?(Integer)
        check_offset(hash_value)
        [calculate_period_from_offset(hash_value)]
      elsif hash_value.is_a?(Date)
        [calculate_period_from_date(hash_value)]
      elsif hash_value.is_a?(Range)
        [calculate_period_from_range(hash_value)]
      else
        raise EnergySparksBadChartSpecification, "Unexpected chart timescale value #{@timescale.class.name} hash value #{hash_value}"
      end
    else
      raise EnergySparksBadChartSpecification, "Unexpected chart timescale type #{@timescale.class.name}"
    end
  end

  protected def new_school_period(start_date, end_date, name_suffix = '')
    SchoolDatePeriod.new(@type, type_name + name_suffix, start_date, end_date)
  end

  protected def calculate_period_from_range(range)
    if range.first.is_a?(Integer) && range.last.is_a?(Integer)
      first_period  = calculate_period_from_offset(range.first)
      last_period   = calculate_period_from_offset(range.last)
      new_school_period(first_period.start_date, last_period.end_date, ' range')
    elsif range.first.is_a?(Date) && range.last.is_a?(Date)
      new_school_period(range.first, range.last, ' range')
    else
      raise EnergySparksUnexpectedStateException, 'Expected range, got nil' if range.nil?
      raise EnergySparksUnexpectedStateException, "Expected range of type Date or Integer, got #{range.first.class.name}"
    end
  end

  protected def weekly_x_axis?
    @chart_config.key?(:x_axis) && @chart_config[:x_axis] == :week
  end
end

class YearPeriods < PeriodsBase
  protected def period_list(first_meter_date = @first_meter_date, last_meter_date = @last_meter_date)
    #avoid skipping a week by aligning to saturday boundary
    move_to_saturday_boundary = weekly_x_axis? ? true : false
    periods = Holidays.years_to_date(first_meter_date, last_meter_date, move_to_saturday_boundary)
    check_or_create_minimum_period(periods)
  end

  def calculate_period_from_offset(offset)
    period_list[offset.magnitude]
  end

  protected def calculate_period_from_date(date)
    Holidays.years_to_date(@first_meter_date, date, true)
  end
end

# e.g. baseload chart, still display if under a years data
class UpToAYearPeriods < YearPeriods
  protected def period_list(first_meter_date = @first_meter_date, last_meter_date = @last_meter_date)
    #avoid skipping a week by aligning to saturday boundary
    move_to_saturday_boundary = weekly_x_axis? ? true : false
    Holidays.periods_cadence(first_meter_date, last_meter_date, include_partial_period: true, move_to_saturday_boundary: move_to_saturday_boundary)
  end
end

class ActivationYearPeriods < YearPeriods
  def period_list(first_meter_date = @first_meter_date, last_meter_date = @last_meter_date)
    # n.b. this is a hash rather than an array, as offset 0 is in the middle of the periods
    @activation_year_list ||= @meter_collection.holidays.activation_years(@meter_collection.energysparks_start_date, first_meter_date, last_meter_date, false)
  end

  def calculate_period_from_offset(offset)
    period_list[offset]
  end

  protected def calculate_period_from_date(_date)
    raise EnergySparksUnsupportedFunctionalityException, 'not implemented for activation years yet'
  end

  protected def check_offset(offset)
    # override test for 0 or -tve offset only as activation years can be positive
  end
end

class NumericPeriods < PeriodsBase
  protected def final_meter_date
    @last_meter_date
  end

  protected def calculate_period_from_offset(offset)
    check_offset(offset)
    end_date = final_meter_date - 7 * offset.magnitude
    start_date = end_date - 6
    new_school_period(start_date, end_date)
  end

  protected def calculate_period_from_date(date)
    end_date = date + 6 > final_meter_date ? final_meter_date : date + 6
    start_date = end_date - 6
    new_school_period(start_date, end_date)
  end
end

class WeekPeriods < NumericPeriods
end

class WorkWeekPeriods < WeekPeriods
  # roll back to Saturday
  protected def final_meter_date
    @last_meter_date - ((@last_meter_date.wday - 6) % 7)
  end
end

class SchoolWeekPeriods < WeekPeriods
  protected def calculate_period_from_offset(offset)
    check_offset(offset)
    sunday, saturday, _week_count = @meter_collection.holidays.nth_school_week(final_meter_date, offset)
    new_school_period(sunday, saturday)
  end
end

# if currently in a holiday, nth_holiday_number = 0 => previous holiday
class HolidayPeriods < WeekPeriods
  protected def calculate_period_from_offset(nth_holiday_number, include_holiday_if_in_date = false)
    check_offset(nth_holiday_number)
    @meter_collection.holidays.find_nth_holiday(@last_meter_date, nth_holiday_number, include_holiday_if_in_date)
  end
end

# include current holiday when offsetting, nth_holiday_number = 0 => this holiday
class InclusiveHolidayPeriods < HolidayPeriods
  protected def calculate_period_from_offset(nth_holiday_number)
    super(nth_holiday_number, true)
  end
end

class DayPeriods < WeekPeriods
  protected def calculate_period_from_offset(offset)
    check_offset(offset)
    end_date = final_meter_date - offset.magnitude
    start_date = end_date
    new_school_period(start_date, end_date)
  end
end

class SchoolDayPeriods < DayPeriods
  protected def calculate_period_from_offset(offset)
    check_offset(offset)
    schoolday_count = 0
    @last_meter_date.downto(@first_meter_date) do |date|
      if @meter_collection.holidays.occupied?(date)
        return new_school_period(date, date) if schoolday_count == offset
        schoolday_count -= 1
      end
    end
  end
end

class WeekendDayPeriods < DayPeriods
  protected def calculate_period_from_offset(offset)
    check_offset(offset)
    weekendday_count = 0
    @last_meter_date.downto(@first_meter_date) do |date|
      if @meter_collection.holidays.weekend?(date)
        return new_school_period(date, date) if weekendday_count == offset
        weekendday_count -= 1
      end
    end
  end
end

class FrostDayPeriods < WeekPeriods
  protected def calculate_period_from_offset(offset)
    check_offset(offset)
    date = list_of_days[offset.magnitude]
    new_school_period(date - days_either_side, date + days_either_side)
  end
  protected def days_either_side; 0 end
  protected def name; 'frost day' end
  protected def list_of_days
    @meter_collection.temperatures.frost_days(@first_meter_date, @last_meter_date, 0, @meter_collection.holidays)
  end
end

class FrostDay3Periods < FrostDayPeriods
  protected def days_either_side; 1 end
end

class DiurnalPeriods < FrostDayPeriods
  protected def name; 'diurnal' end
  protected def list_of_days
    @meter_collection.temperatures.largest_diurnal_ranges(@first_meter_date, @last_meter_date, true, false, @meter_collection.holidays, false)
  end
end

class OptimumStartPeriods < FrostDayPeriods
  protected def name; 'optimum start' end
  protected def list_of_days
    raise EnergySparksChartNotRelevantForSchoolException, 'optimum start chart not relevant for school where gas not used for heating' if @meter_collection.non_heating_only?
    @optimum_start_days ||= OptimumStartDates.new(@meter_collection).list_of_dates
  end

  # returns weeks as list of 5 dates at a time

end

class MonthPeriods < NumericPeriods
  protected def calculate_period_from_offset(offset)
    check_offset(offset)
    offset_month = @last_meter_date.prev_month(-offset)
    first_day_of_month = Date.new(offset_month.year, offset_month.month, 1)
    last_day_of_month = DateTimeHelper.last_day_of_month(offset_month)
    last_day_of_month = @last_meter_date if offset == 0 && last_day_of_month > @last_meter_date # partial month
    new_school_period(first_day_of_month, last_day_of_month)
  end
end

class DateRangePeriods < NumericPeriods
  protected def calculate_period_from_offset(array_of_2_dates)
    new_school_period(array_of_2_dates[0], array_of_2_dates[1])
  end
end

class HotWaterPeriod < NumericPeriods
  def periods
    period = new_school_period(hotwater_model.analysis_period_start_date, hotwater_model.analysis_period_end_date)
    @periods = [period]
  end
  private def hotwater_model
    @hotwater_model ||= AnalyseHeatingAndHotWater::HotwaterModel.new(@meter_collection)
  end
end

class NoPeriod < NumericPeriods
  def periods
    [new_school_period(@first_meter_date, @last_meter_date)]
  end
end
