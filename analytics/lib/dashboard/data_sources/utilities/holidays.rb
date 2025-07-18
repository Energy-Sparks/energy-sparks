require_relative 'school_date_period.rb'

# single holiday period
class Holiday < SchoolDatePeriod
  attr_accessor :type           # :easter, :xmas, autumn_halfterm etc.
  attr_accessor :academic_year  # e.g. 2018..2019
  def initialize(type, name, start_date, end_date, academic_year)
    start_date = roll_start_date_back_to_sunday(start_date) unless type == :inset_day_in_school
    end_date = roll_end_date_forward_to_saturday(end_date)  unless type == :inset_day_in_school
    name = Holidays.holiday_name(middle_date(start_date, end_date)) if name.nil? || name == 'No title'
    super(:holiday, name, start_date, end_date)
    @type = type
    @academic_year = academic_year
    raise EnergySparksNoMeterDataAvailableForFuelType.new('Start date after end date') if start_date > end_date
  end

  def number_weekdays
    d = 0
    (start_date..end_date).each do |date|
      d += 1 if date.wday.between?(1,5)
    end
    d
  end

  private def roll_start_date_back_to_sunday(start_date)
    return start_date - 1 if start_date.monday?
    start_date
  end

  private def roll_end_date_forward_to_saturday(end_date)
    return end_date + 1 if end_date.friday?
    end_date
  end

  def middle_date(start_date = @start_date, end_date = @end_date)
    start_date + ((end_date - start_date) / 2).to_i
  end

  def to_s
    super + ' ' + @type.to_s + ' ' + (@academic_year.nil? ? '' : @academic_year.first.to_s + '/' + @academic_year.last.to_s)
  end

  def translation_type
    # set_holiday_types overwrites the type using Holidays.holiday_type but only does so for @holidays and not
    # @additional_holidays so Mayday doesn't get set as it is classed as additional being a bank holiday
    Holidays.holiday_type(middle_date)
  end
end

# holds holiday data as an array of hashes - one hash for each holiday period
class HolidayData < Array
  include Logging

  def add(holiday)
    self.push(holiday)
  end
end

# loads holiday data (from a CSV file), assumes added in date order!
class HolidayLoader
  include Logging

  def initialize(csv_file, holiday_data)
    read_csv(csv_file, holiday_data)
  end

  def read_csv(csv_file, holidays)
    logger.debug "Reading Holiday data from '#{csv_file}'"
    datareadings = Roo::CSV.new(csv_file)
    count = 0
    datareadings.each do |reading|
      holiday_type = reading[0].to_sym
      raise EnergySparksBadHolidayDataException, "Unknown holiday type #{holiday_type}" if !%i[bank_holiday inset_day_in_school inset_day_out_of_school school_holiday].include?(holiday_type)
      title = reading[1]
      start_date = Date.parse reading[2]
      end_date = Date.parse reading[3]
      holidays.add(Holiday.new(holiday_type, title, start_date, end_date, nil))
      count += 1
    end
    logger.debug "Read #{count} rows"
    logger.debug "Read #{holidays.length} rows"
  end
end

# contains holidays, plus functionality for determining whether a date is a holiday
class Holidays
  include Logging
  attr_reader :holidays
  MAIN_HOLIDAY_TYPES = %i[autumn_half_term xmas spring_half_term easter summer_half_term summer]

  def initialize(holiday_data, country = nil)
    @country = country
    set_holidays_by_type(holiday_data)
    # remove_non_holidays
    set_holiday_types_and_academic_years
    @cached_holiday_lookup = {} # for speed,
  end

  def print
    @holidays.each do |holiday|
      puts holiday
    end
  end

  # once all the data is loaded, set type enumerations e.g. :easter
  # and academic year e.g. 2018..2019 against each holiday
  private def set_holiday_types_and_academic_years
    set_holiday_types
    set_academic_years
    check_consistency
  end

  private def remove_non_holidays
    @holidays.reject! { |holiday| %i[bank_holiday inset_day_in_school inset_day_out_of_school].include?(holiday.type) } # not :school_holiday
  end

  private def set_holidays_by_type(holidays)
    @holidays            = filter_and_sort_holidays(holidays, %i[school_holiday])
    @additional_holidays = filter_and_sort_holidays(holidays, %i[bank_holiday inset_day_out_of_school])
    @school_days         = filter_and_sort_holidays(holidays, %i[inset_day_in_school] )
  end

  private def sort_holidays(holidays)
    holidays.sort_by(&:start_date)
  end

  private def filter_and_sort_holidays(holidays, types)
    filtered_holidays = holidays.select{ |holiday| types.include?(holiday.type) }
    sort_holidays(filtered_holidays)
  end

  private def set_holiday_types
    @holidays.each do |holiday|
      holiday.type = type(holiday.middle_date)
    end
  end

  private def set_academic_years
    @holidays.each do |holiday|
      if holiday.middle_date.month > 8
        holiday.academic_year = holiday.middle_date.year..(holiday.middle_date.year + 1)
      else
        holiday.academic_year = (holiday.middle_date.year - 1)..holiday.middle_date.year
      end
    end
  end

  private def check_consistency
    logger.info 'Checking for consistency of recently loaded holiday data'
    types_grouped_by_academic_year = Hash.new([])
    @holidays.each do |holiday|
      next unless types_grouped_by_academic_year.key?(holiday.academic_year)
      unless types_grouped_by_academic_year[holiday.academic_year].find { |hol| hol.type == holiday.type }.nil?
        logger.error "2 holidays of same time #{holiday.type} in same academic year #{holiday.academic_year.first}/#{holiday.academic_year.first}"
      end
    end
    logger.info 'Holiday check complete'
  end

  def holiday?(date)
    !holiday(date).nil?
  end

  def occupied?(date)
    !weekend?(date) && !holiday?(date)
  end

  def day_type_statistics(start_date, end_date)
    stats = {
      holiday:    0,
      weekend:    0,
      schoolday:  0
    }
    (start_date..end_date).each do |date|
      stats[day_type(date)] += 1
    end
    stats
  end

  # Calculates summary usage statistics between 2 dates.
  #
  # The lambda argument should be a lambda function that returns the usage for a
  # specific date. Additional arguments for the function are provided via the +args+ param.
  #
  # The classifier argument classifies each day into a type. By default it uses +day_type+
  # but this can be altered to use custom groupings.
  #
  # The list of statistics to be generates are provided via the +statistics+ parameter.
  #
  # The function is currently only used for the holida usage alert. It could be moved into
  # that class or be turned into a more general purpose utility, as it is not strictly
  # speaking limited to summarising holiday usage.
  def calculate_statistics(start_date, end_date, lambda, args: nil, classifier: -> (date) { day_type(date) }, statistics: %i[total average min max count])
    totals = {}
    stats = {}

    (start_date..end_date).each do |date|
      dt = classifier.call(date)
      totals[dt] ||= []
      result = args.nil? ? lambda.call(date): lambda.call(date, *args)
      totals[dt].push(result)
    end

    totals.each do |daytype, total|
      stats[daytype] ||= {}
      statistics.each do |statistic_type|
        case statistic_type
        when :total
          stats[daytype][statistic_type] = total.sum
        when :average
          stats[daytype][statistic_type] = total.length == 0 ? nil : total.sum / total.length
        when :min
          stats[daytype][statistic_type] = total.min
        when :max
          stats[daytype][statistic_type] = total.max
        when :count
          stats[daytype][statistic_type] = total.length
        when :data
          stats[daytype][statistic_type] = total
        end
      end
    end

    stats
  end

  def day_type(date)
    if holiday?(date)
      :holiday
    elsif weekend?(date)
      :weekend
    else
      :schoolday
    end
  end

  def last
    @holidays.last
  end

  # returns a holiday period corresponding to a date, nil if not a date
  def holiday(date)
    # check cache, as lookup currently loops through list of holidays
    # speeds up this function for 48x365 lookup report by 0.5s (0.6s to 0.1s)
    if @cached_holiday_lookup.key?(date)
      return @cached_holiday_lookup[date]
    end
    @cached_holiday_lookup[date] = is_holiday(date)
    @cached_holiday_lookup[date]
  end

  def is_holiday(date)
    return nil unless find_holiday(date, @school_days).nil? # inset day out of school not a holiday

    school_holiday      = find_holiday(date, @holidays)
    return school_holiday       unless school_holiday.nil?

    public_or_inset_day = find_holiday(date, @additional_holidays)
    return public_or_inset_day  unless public_or_inset_day.nil?

    # TODO(PH, 17Nov2019) check for weekend gap between 2 holidays here - complex & difficult, but not critical
    nil # no holiday
  end

  def is_weekend(date)
    date.saturday? || date.sunday?
    raise 'Deprecated'
  end

  def weekend?(date)
    date.saturday? || date.sunday?
  end

  # returns a hash defining a holiday :title => title, :start_date => start_date, :end_date => end_date} or nil
  def find_holiday(date, holiday_schedule = @holidays, min_days_in_holiday = nil)
    SchoolDatePeriod.find_period_for_date(date, holiday_schedule, min_days_in_holiday)
  end

  def find_next_holiday(date, max_days_search = 100, min_days_in_holiday = nil)
    find_holiday_with_offset(date, max_days_search, 1, min_days_in_holiday)
  end

  def find_previous_or_current_holiday(date, max_days_search = 100, min_days_in_holiday = nil)
    find_holiday_with_offset(date, max_days_search, -1, min_days_in_holiday)
  end

  def find_previous_holiday_to_current(current_holiday, number_holidays_before = 1, min_days_in_holiday = nil)
    raise EnergySparksUnexpectedStateException, "number holidays before = #{number_holidays_before} needs to be > 0" if number_holidays_before <= 0

    holiday_index = SchoolDatePeriod.find_period_index_for_date(current_holiday.middle_date, @holidays)

    while number_holidays_before > 0 && holiday_index > 0
      if min_days_in_holiday.nil? || @holidays[holiday_index - 1].weekdays >= min_days_in_holiday
        number_holidays_before -= 1
      end
      holiday_index -= 1
    end

    holiday_index < 0 || number_holidays_before > 0 ? nil : @holidays[holiday_index]
  end

  private def find_holiday_with_offset(date, max_days_search = 100, direction = 1, min_days_in_holiday = nil)
    (0..max_days_search).each do |days|
      period = SchoolDatePeriod.find_period_for_date(date + direction * days, @holidays, min_days_in_holiday)
      return period unless period.nil?
    end
    nil
  end

  def same_holiday_previous_year(this_years_holiday_period, max_days_search = 365 + 100)
    this_years_holiday_mid_date = this_years_holiday_period.start_date + (this_years_holiday_period.days / 2).floor
    this_years_holiday_type = type(this_years_holiday_mid_date)
    # start 200 days back, the only real concern is to mis Easter which moves by up to ~40 days
    (200..max_days_search).each do |num_days_offset_backwards|
      date = this_years_holiday_period.start_date - num_days_offset_backwards
      last_years_holiday_period = find_holiday(date)
      unless last_years_holiday_period.nil?
        last_years_holiday_mid_date = last_years_holiday_period.start_date + (last_years_holiday_period.days / 2).floor
        last_years_holiday_type = type(last_years_holiday_mid_date)
        return last_years_holiday_period if this_years_holiday_type == last_years_holiday_type
      end
    end
    nil
  end

  def self.holiday_month_year_str(holiday)
    I18n.t("analytics.holiday_year", holiday: I18nHelper.holiday(holiday.type), year: holiday.start_date.year.to_s)
  end

  # finds nth holiday before or after date, including/excluding current holiday if date within a holiday
  # Test Code:
  # [-100, -2, -1, 0, 1, 2, 50].each do |nth_holiday_number|
  #  [true, false].each do |include_holiday_if_in_date|
  #     [Date.new(2019,6,25), Date.new(2019,8,15), Date.new(1999,1,1), Date.new(2030,1,1)].each do |date|
  #       hol = @school.holidays.find_nth_holiday(date, nth_holiday_number, include_holiday_if_in_date)
  #       puts "#{date} #{nth_holiday_number} #{include_holiday_if_in_date}: #{hol}"
  #    end
  #   end
  # end
  #
  def find_nth_holiday(date, nth_holiday_number, include_holiday_if_in_date = false)
    nearest_holiday_index = find_nearest_holiday_index(@holidays, date, include_holiday_if_in_date)
    return nil if nearest_holiday_index.nil?
    holiday_index = nearest_holiday_index + nth_holiday_number
    return nil if holiday_index < 0 || holiday_index >= @holidays.length
    @holidays[holiday_index]
  end

  def number_holidays_between_dates(start_date, end_date, include_holiday_if_in_date = false)
    end_date_holiday_index = find_nearest_holiday_index(@holidays, end_date, include_holiday_if_in_date)
    raise EnergySparksNotEnoughDataException, "Not enough holiday data for meter end date #{end_date}" if end_date_holiday_index.nil?
    start_date_holiday_index = find_nearest_holiday_index(@holidays, end_date, false)
    raise EnergySparksNotEnoughDataException, "Not enough holiday data for meter start date #{start_date}" if start_date_holiday_index.nil?
    end_date_holiday_index - start_date_holiday_index # could possibly be +1????
  end

  private def find_nearest_holiday_index(holidays, date, include_holiday_if_in_date = false)
    holidays.each_with_index do |holiday, index|
      return index if include_holiday_if_in_date && date.between?(holiday.start_date, holiday.end_date)
      return index - 1 if date.between?(holiday.start_date, holiday.end_date)
      return index if index < holidays.length - 1 && date > holiday.end_date && date < holidays[index + 1].start_date
    end
    nil
  end

  def find_summer_holiday_before(date)
    @holidays.reverse.each do |hol|
      # identify summer holiday by length, then month (England e.g. Mon 9 Jul 2018 - Wed 4 Sep 2018  Scotland e.g. Mon 1 Jul 2019 - 13 Aug 2019

      days_in_holiday = (hol.end_date - hol.start_date + 1).to_i
      if days_in_holiday > 4 * 7 && date > hol.end_date
        return hol
      end
    end
    nil
  end

  def find_all_summer_holidays_date_range(start_date, end_date)
    summer_holidays = []
    summer_holiday = find_summer_holiday_before(end_date)
    while !summer_holiday.nil? do
      summer_holidays.push(summer_holiday)
      summer_holiday = find_summer_holiday_before(summer_holiday.start_date - 1)
    end
    summer_holidays
  end

  def find_summer_holiday_after(date)
    @holidays.each do |hol|
      # identify summer holiday by length, then month (England e.g. Mon 9 Jul 2018 - Wed 4 Sep 2018  Scotland e.g. Mon 1 Jul 2019 - 13 Aug 2019

      days_in_holiday = (hol.end_date - hol.start_date + 1).to_i
      if days_in_holiday > 4 * 7 && date < hol.start_date
        return hol
      end
    end
    nil
  end

  # iterate backwards to find nth school week before date, skipping holidays
  # last week = 0, previous school week = -1, iterates on Sunday-Saturday boundary
  def nth_school_week(asof_date, nth_week_number, min_days_in_school_week = 3, min_date = nil)
    raise EnergySparksBadChartSpecification.new("Badly specified nth_school_week #{nth_week_number} must be zero or negative") if nth_week_number > 0
    raise EnergySparksBadChartSpecification.new("Badly specified min_days_in_school_week #{min_days_in_school_week} must be > 0") if min_days_in_school_week <= 0
    limit = 2000
    week_count = nth_week_number.magnitude
    saturday = asof_date.saturday? ? asof_date : self.class.nearest_previous_saturday(asof_date)
    loop do
      break if !min_date.nil? && saturday <= min_date
      monday = saturday - 5
      friday = saturday - 1
      holiday_days_in_week = holidaydays_in_range(monday, friday)
      week_count -= 1 unless holiday_days_in_week > (5 - min_days_in_school_week)
      break if week_count < 0
      saturday = saturday - 7
      limit -= 1
      raise EnergySparksUnexpectedStateException.new('Gone too many times around loop looking for school weeks, not sure why error has occurred') if limit <= 0
    end
    [saturday - 6, saturday, week_count]
  end

  # not sure whether it includes current Saturday, assume not, so if date is already a Saturday, returns date - 7
  def self.nearest_previous_saturday(date)
    date - (date.wday + 1)
  end

  def holidaydays_in_range(start_date, end_date)
    count = 0
    (start_date..end_date).each do |date|
      count += 1 if holiday?(date)
    end
    count
  end

  def academic_year_tolerant_of_missing_data(date)
    calculate_academic_year_tolerant_of_missing_data(date)
  end

  def calculate_academic_year_tolerant_of_missing_data(date)
    year = academic_year(date)
    if year.nil?
      # data commonly not being set for next summer holiday, so make a guess!!!!!!!!!!!
      previous_academic_year = academic_year(date - 364)
      year = SchoolDatePeriod.new(:academic_year, 'Synthetic approx current academic year', previous_academic_year.end_date + 1, previous_academic_year.end_date + 365)
    end
    year
  end

  # returns a list of academic years between 2 dates - iterates backwards from most recent end of summer holiday
  def academic_years(start_date, end_date)
    acy_years = []

    last_summer_hol = find_summer_holiday_before(end_date)

    until last_summer_hol.nil? do
      previous_summer_hol = find_summer_holiday_before(last_summer_hol.start_date - 1)
      return acy_years if previous_summer_hol.nil?
      return acy_years if previous_summer_hol.end_date < start_date

      acy_years.push(AcademicYear.new(previous_summer_hol.end_date + 1, last_summer_hol.end_date, @holidays))

      last_summer_hol = previous_summer_hol
    end
    acy_years
  end

  # currently in Class Holidays, but doesn't use holidays, so could be self, mirrors academic_years method above
  def self.years_to_date(start_date, end_date, move_to_saturday_boundary)
    yrs_to_date = []

    # move to previous Saturday, so last date a Saturday - better for
    # getting weekends and holidays on right boundaries
    last_date_of_period = move_to_saturday_boundary ? nearest_previous_saturday(end_date) : end_date

    # iterate backwards creating a year periods until we run out of AMR data
    first_date_of_period = last_date_of_period - 52 * 7 + 1

    while first_date_of_period >= start_date
      # add a new period to the return array
      year_description = "year to " << last_date_of_period.strftime("%a %d %b %y")
      yrs_to_date.push(SchoolDatePeriod.new(:year_to_date, year_description, first_date_of_period, last_date_of_period))

      # move back 52 weeks
      last_date_of_period = first_date_of_period - 1
      first_date_of_period = last_date_of_period - 52 * 7 + 1
    end

    yrs_to_date
  end

  def self.reverse_date_range_periods(start_date, end_date, period_length, include_partial_period)
    Enumerator.new do |enum|
      range_end = end_date
      loop do
        range_start = range_end - (period_length - 1)
        break unless range_start >= start_date

        enum << [range_start, range_end]
        range_end = range_start - 1
      end
      enum << [start_date, range_end] if include_partial_period && range_end >= start_date
    end
  end

  # Currently only used by the ChartManagerTimescaleManipulation and UpToAYearPeriods
  def self.periods_cadence(start_date, end_date, cadence_days: 52 * 7, include_partial_period: false, move_to_saturday_boundary: false, minimum_days: nil)
    last_date_of_period = if move_to_saturday_boundary && !end_date.saturday?
                            nearest_previous_saturday(end_date)
                          else
                            end_date
                          end
    cadence = :"cadence_#{cadence_days}_days"
    periods = reverse_date_range_periods(start_date, last_date_of_period, cadence_days, include_partial_period)
              .map.with_index do |period, i|
      description = "period #{-i} cadence #{cadence_days}"
      SchoolDatePeriod.new(cadence, description, period[0], period[1])
    end
    periods.reject! { |period| period.days < minimum_days } if minimum_days
    periods
  end

  # differs from 'year_to_date' as datum (0) if first whole year before activation
  # date hence return a hash, rather than an array, as offset is 2 directional
  def activation_years(activation_date, start_date, end_date, move_to_saturday_boundary)
    yrs_to_date = {}

    last_date_of_period = end_date

    last_date_of_period = self.class.nearest_previous_saturday(last_date_of_period) if move_to_saturday_boundary

    # go backwards
    offset = 0
    while activation_date - 365 * offset > start_date
      year_description = "#{offset.magnitude} years before activation date year"
      start_of_year = activation_date - 365 * (offset + 1)
      end_of_year   = start_of_year + 364
      year = SchoolDatePeriod.new(:activationyear, year_description, start_of_year, end_of_year)
      yrs_to_date[-offset] = year
      offset += 1
    end

    # go forwards
    offset = 0
    while activation_date + 365 * offset < end_date
      year_description = "#{offset} years after activation date year"
      start_of_year = activation_date + 365 * (offset - 1)
      end_of_year   = start_of_year + 364
      year = SchoolDatePeriod.new(:activationyear, year_description, start_of_year, end_of_year)
      yrs_to_date[offset] = year
      offset += 1
    end

    yrs_to_date
  end


  class AcademicYear < SchoolDatePeriod
    include Logging
    attr_reader :holidays_in_year
    def initialize(start_date, end_date, full_holiday_schedule)
      # this is called from meter validation and equivalences with slightly different
      # structures TODO(PH,24Nov2019) normalise upstream so switch not required
      schedule = full_holiday_schedule.is_a?(Array) ? full_holiday_schedule : full_holiday_schedule.holidays
      year_name = start_date.year.to_s + '/' + end_date.year.to_s
      super(:academic_year, year_name, start_date, end_date)
      @holidays_in_year = find_holidays_in_year(schedule)
    end

    def find_holidays_in_year(full_holiday_schedule)
      hols = []
      full_holiday_schedule.each do |hol|
        if hol.start_date >= start_date && hol.end_date <= end_date
          hols.push(hol)
        end
      end
      hols
    end
  end

  def academic_year(date)
    summer_hol_before = find_summer_holiday_before(date)
    summer_hol_after = find_summer_holiday_after(date)
    if summer_hol_before.nil? || summer_hol_after.nil?
      logger.debug "Warning: unable to find academic year for date #{date}"
      nil
    else
      acy_year = AcademicYear.new(summer_hol_before.end_date + 1, summer_hol_after.end_date, @holidays)
      # logger.debug "Found academic year for date #{date} - year from #{acy_year.start_date} #{acy_year.end_date}"
      acy_year
    end
  end

  # returns current academic year if n = 0, next if n = 1, 2 before if n = -2
  def nth_academic_year_from_date(n, date, raise_exception = true)
    this_year = academic_year(date)
    raise EnergySparksUnexpectedStateException.new("Cannnot find current academic year for date #{date}") if this_year.nil?
    # slightly crude way of doing this
    mid_point_of_year = this_year.start_date + 180
    day_in_middle_of_wanted_year = mid_point_of_year + n * 365
    wanted_year = academic_year(day_in_middle_of_wanted_year)
    raise EnergySparksUnexpectedStateException.new("Cannnot find #{n}th academic year for date #{date}") if wanted_year.nil? && raise_exception
    wanted_year
  end

  def find_holiday_in_academic_year(academic_year, holiday_type)
    hol = find_holiday_in_academic_year_private(academic_year, holiday_type)
    if hol.nil?
      logger.debug "Unable to find holiday of type #{holiday_type} in academic year #{academic_year.start_date} to #{academic_year.end_date}"
    end
    hol
  end

  # for holidays types see code
  def find_holiday_in_academic_year_private(academic_year, holiday_type)
    academic_year.holidays_in_year.each do |hol|
      case holiday_type
      when :xmas
        return hol if hol.start_date.month == 12 && hol.days > 5
      when :spring_half_term
        return hol if (hol.start_date.month == 2 || (hol.start_date.month == 1 && hol.end_date.month == 2)) && hol.days > 3
      when :easter
        return hol if (hol.start_date.month == 3 || hol.start_date.month == 4) && hol.days > 4
      when :mayday
        return hol if hol.start_date.month == 5 && hol.days <= 2
      when :summer_half_term
        if (hol.start_date.month == 5 || (hol.start_date.month == 6 && hol.start_date.day < 10)) &&
          hol.days > 2
          return hol
        end
      when :summer
        return hol if (hol.start_date.month == 6 || hol.start_date.month == 7) && hol.days > 10
      when :autumn_half_term
        return hol if hol.start_date.month == 10 && hol.days > 3
      else
        raise EnergySparksUnexpectedStateException.new("Unknown holiday type #{holiday_type}")
      end
    end
    nil
  end

  # returns which holiday this is, not self as may eventually
  # have to reference its own holiday schedule
  # would be best if list were an enumeration, but these aren't supported outside rails
  def self.holiday_type(date)
    case date.month
    when 1, 12
      :xmas
    when 2
      :spring_half_term
    when 3, 4
      :easter
    when 5
      if date.day < 15
        :mayday
      else
        :summer_half_term
      end
    when 6
      if date.day < 12
        :summer_half_term
      elsif date.day > 24
        :summer # Inverness High School: June 2021
      else
        nil
      end
    when 7, 8
      :summer
    when 9
      if date.day < 15 # Scotland has a one off holiday later in September
        :summer
      else
        nil
      end
    when 10, 11
      :autumn_half_term
    else
      nil
    end
  end

  def self.new_year_year(date)
    year = date.year
    if date.mon == 12
      year.to_s + '/' + (year + 1).to_s
    else
      (year - 1).to_s + '/' + year.to_s
    end
  end

  def self.holiday_name(date)
    type = holiday_type(date)
    year = type == :xmas ? new_year_year(date) : date.year.to_s
    type.to_s.humanize + ' ' + year
  end

  def new_year_year(date)
    year = date.year
    if date.mon == 12
      year.to_s + '/' + (year + 1).to_s
    else
      (year - 1).to_s + '/' + year.to_s
    end
  end

  def type(date)
    self.class.holiday_type(date)
  end
end
