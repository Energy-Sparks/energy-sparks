# frozen_string_literal: true

class SchoolDatePeriod
  include Logging

  attr_reader :type, :title, :start_date, :end_date

  def initialize(type, title, start_date, end_date)
    raise ArgumentError, "nil date provided #{start_date}-#{end_date}" if start_date.nil? || end_date.nil?
    if end_date < start_date
      raise EnergySparksUnexpectedStateException,
            "invalid range provided #{end_date} before start date #{start_date}"
    end

    @type = type
    @title = title
    @start_date = start_date
    @end_date = end_date
  end

  # Implement equality such that a period can be used in a composite hash key
  # Title is treated as a comment, so only checking type and dates
  def ==(other)
    other.is_a?(SchoolDatePeriod) && type == other.type && start_date == other.start_date && end_date == other.end_date
  end
  alias eql? ==

  def hash
    [self.class, type, start_date, end_date].hash
  end

  def to_s
    "#{@title} (#{start_date.strftime('%a %d %b %Y')} to #{end_date.strftime('%a %d %b %Y')})"
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
    days - (2 * saturdays) - (start_date.wday.zero? ? 1 : 0) + (end_date.wday == 6 ? 1 : 0)
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

  def self.find_period_for_date(date, periods, min_period_length_days = nil)
    periods = remove_short_holidays(periods, min_period_length_days) unless min_period_length_days.nil?
    nil
    if periods.length > 1 && periods[0].start_date < periods[1].start_date
      periods.bsearch do |p|
        if date < p.start_date
          -1
        else
          date > p.end_date ? 1 : 0
        end
      end
    else # reverse sorted array
      periods.bsearch do |p|
        if date < p.start_date
          1
        else
          date > p.end_date ? -1 : 0
        end
      end
    end
  end

  # e.g. 'May Day' might be defined in some circumstances
  # as not being a real school holiday for analysis
  def self.remove_short_holidays(periods, min_period_length_days)
    periods.select { |period| period.weekdays >= min_period_length_days }
  end

  def self.find_period_index_for_date(date, periods)
    count = 0
    periods.each do |period|
      raise "Bad date#{date}#{period}" if date.nil? || period.nil? || period.start_date.nil? || period.end_date.nil?
      return count if date.between?(period.start_date, period.end_date)

      count += 1
    end
    nil
  end

  def to_a
    [type, title, start_date, end_date]
  end
end
