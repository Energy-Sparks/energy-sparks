class SchoolDatePeriod
  class EndDateBeforeStartDate < StandardError; end
  include Logging

  attr_reader :type, :title, :start_date, :end_date, :calendar_event_type_id
  def initialize(type, title, start_date, end_date)
    raise EndDateBeforeStartDate, "period end date #{end_date} before period start date #{start_date}" if end_date < start_date
    @type = type
    @title = title
    @start_date = check_is_date(start_date, 'start date')
    @end_date = check_is_date(end_date, 'end date')
    @calendar_event_type_id = @calendar_event_type_id
  end

  def to_s
    "" << @title << ' (' << start_date.strftime("%a %d %b %Y") << ' to ' << end_date.strftime("%a %d %b %Y") << ')'
  end

  def days
    (@end_date - @start_date + 1).to_i
  end

  def self.year_to_date(type, title, end_date, limit_start_date = nil)
    # use 364 = 52 weeks rather than 365, as works better with weekly aggregation etc.
    start_date = limit_start_date.nil? ? end_date - 364 : [end_date - 364, limit_start_date].max
    SchoolDatePeriod.new(type, title, start_date, end_date)
  end

  def dates
    (start_date..end_date).to_a
  end

  def self.number_of_weekdays(period)
    weekdays_inclusive(period.start_date, period.end_date)
  end

  def self.weekdays_inclusive(start_date, end_date)
    days = (end_date - start_date + 1).to_i
    saturdays = ((days + start_date.wday) / 7).to_i
    days - 2 * saturdays - (start_date.wday == 0 ? 1 : 0) + (end_date.wday == 6 ? 1 : 0)
  end

  # fast calculation - no looping
  #   weekdays(Date.new(2020, 6,  1), Date.new(2020, 6, 1)) => 1 - Mon to Mon
  #   weekdays(Date.new(2020, 5, 31), Date.new(2020, 6, 1)) => 1 - Sun to Mon
  #   weekdays(Date.new(2020, 5, 31), Date.new(2020, 6, 6)) => 5 - Sun to Sat
  #   weekdays(Date.new(2020, 5, 31), Date.new(2020, 6, 8)) => 6 - Sun to Mon
  def weekdays
    SchoolDatePeriod.number_of_weekdays(self)
  end

  def self.matching_dates_in_period_to_day_of_week_list(period, list_of_days_of_week)
    (period.start_date..period.end_date).to_a.select { |date| list_of_days_of_week.include?(date.wday) }
  end

  def self.merge_two_periods(period_1, period_2)
    if period_1.start_date >= period_2.start_date && period_1.end_date >= period_2.end_date
      SchoolDatePeriod.new(period_1.type, period_1.title + 'merged', period_2.start_date, period_1.end_date)
    elsif period_2.start_date >= period_1.start_date && period_2.end_date >= period_1.end_date
      SchoolDatePeriod.new(period_2.type, period_2.title + 'merged', period_1.start_date, period_2.end_date)
    else
      raise EnergySparksUnexpectedStateException.new('Expected School Period merge request for overlapping date ranges')
    end
  end

  def self.find_period_for_date(date, periods, min_period_length_days = nil)
    periods = remove_short_holidays(periods, min_period_length_days) unless min_period_length_days.nil?
    period = nil
    if periods.length > 1 && periods[0].start_date < periods[1].start_date
      period = periods.bsearch {|p| date < p.start_date ? -1 : date > p.end_date ? 1 : 0 }
    else  # reverse sorted array
      period = periods.bsearch {|p| date < p.start_date ? 1 : date > p.end_date ? -1 : 0 }
    end
    period
  end

  # e.g. 'May Day' might be defined in some circumstances
  # as not being a real school holiday for analysis
  def self.remove_short_holidays(periods, min_period_length_days)
    periods.select{ |period| period.weekdays >= min_period_length_days }
  end


  def self.find_period_for_date_deprecated(date, periods, min_period_length_days = nil)
    periods = remove_short_holidays(periods, min_period_length_days) unless min_period_length_days.nil?
    periods.each do |period|
      if date.nil? || period.nil? || period.start_date.nil? || period.end_date.nil?
        raise "Bad date" + date + period
      end
      if date >= period.start_date && date <= period.end_date
        return period
      end
    end
    nil
  end

  def self.find_period_index_for_date(date, periods)
    count = 0
    periods.each do |period|
      if date.nil? || period.nil? || period.start_date.nil? || period.end_date.nil?
        raise "Bad date" + date + period
      end
      if date >= period.start_date && date <= period.end_date
        return count
      end
      count += 1
    end
    nil
  end

  def self.info_compact(periods, columns = 3, with_count = true, date_format = '%a %d%b%y')
    periods.each_slice(columns).to_a.each do |group_period|
      line = '  '
      group_period.each do |period|
        d1 = period.start_date.strftime(date_format)
        d2 = period.end_date.strftime(date_format)
        length = period.end_date - period.start_date + 1
        line += " #{d1} to #{d2}" + (with_count ? sprintf(' * %3d', length) : '')
      end
      Logging.logger.info line
    end
  end

  def to_a
    [type, title, start_date, end_date]
  end

  private def check_is_date(date, name)
    raise EnergySparksUnexpectedStateException, "Unexpected nil #{name}" if date.nil?
    raise EnergySparksUnexpectedStateException, "Unexpected #{name} of type #{date.class.name} expecting a Date" unless date.is_a?(Date)
    date
  end
end
