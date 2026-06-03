# frozen_string_literal: true

class OpenCloseTime
  SCHOOL_OPEN                 = :school_day_open
  SCHOOL_CLOSED               = :school_day_closed
  HOLIDAY                     = :holiday
  WEEKEND                     = :weekend
  COMMUNITY                   = :community
  COMMUNITY_BASELOAD          = :community_baseload

  COMMUNITY_I18N_KEY          = 'community'
  COMMUNITY_BASELOAD_I18N_KEY = 'community_baseload'

  def initialize(open_close_time, holidays)
    @open_close_time = open_close_time
    @holidays = holidays
  end

  def self.community
    humanize_symbol(COMMUNITY)
  end

  def self.community_baseload
    humanize_symbol(COMMUNITY_BASELOAD)
  end

  def self.day_of_week_types
    %i[
      weekdays
      weekends
      everyday
      monday
      tuesday
      wednesday
      thursday
      friday
      saturday
      sunday
    ]
  end

  def self.calendar_types
    %i[
      follows_school_calendar
      no_holidays
      holidays_only
    ]
  end

  # e.g. flood lighting which might be electricity only
  def self.fuel_type_choices
    %i[
      both
      electricity_only
      gas_only
      none
    ]
  end

  def self.open_time_keys
    %i[time0 time1 time2 time3]
  end

  def self.user_configurable_community_use_types
    @@user_configurable_community_use_types ||= community_use_types.reject do |_type, config|
      config[:user_configurable] == false
    end
  end

  def self.non_user_configurable_community_use_types
    @@non_user_configurable_community_use_types ||= community_use_types.select do |_type, config|
      config[:user_configurable] == false
    end
  end

  def self.community_use_types
    @@community_use_types ||= {
      SCHOOL_CLOSED => { user_configurable: false, sort_order: 1 },
      SCHOOL_OPEN => { sort_order: 2 },
      WEEKEND => { user_configurable: false, sort_order: 3 },
      HOLIDAY => { user_configurable: false, sort_order: 4 },
      COMMUNITY_BASELOAD => { community_use: true, sort_order: 5, benchmark_code: 'b' },
      COMMUNITY => { community_use: true, sort_order: 6, benchmark_code: 'c' },
      dormitory: { community_use: true, sort_order: 7, benchmark_code: 'd' },
      sports_centre: { community_use: true, sort_order:  8, benchmark_code: 's' },
      swimming_pool: { community_use: true, sort_order:  9, benchmark_code: 's' },
      kitchen: { community_use: true, sort_order: 10, benchmark_code: 'k' },
      library: { community_use: true, sort_order: 11, benchmark_code: 'l' },
      flood_lighting: { community_use: true, sort_order: 12, benchmark_code: 'f', fuel_type: :electricity },
      other: { community_use: true, sort_order: 13, benchmark_code: 'o' }
    }
  end

  def self.humanize_symbol(k)
    k.is_a?(Symbol) ? k.to_s.split('_').map(&:capitalize).join(' ') : k
  end

  def self.community_usage_types
    @@community_usage_types ||= community_use_types.select { |_type, config| config[:community_use] == true }.keys
  end

  def type
    @open_close_time[:type]
  end

  def matched_usage?(date)
    matches_start_end_date?(date) &&
      match_holiday?(date) &&
      match_weekday?(date)
  end

  # aka extract_times_for_week_day
  def time_ranges_for_week_day(date)
    matching_times = []

    open_close_times.each do |open_close_time|
      matching_times.push(open_close_time[:from]..open_close_time[:to]) if matches_weekday?(date, open_close_time)
    end

    matching_times
  end

  private

  def calendar_type
    @open_close_time[:holiday_calendar]
  end

  def match_holiday?(date)
    case calendar_type
    when :no_holidays # open 52 weeks of year
      true
    when :holidays_only
      @holidays.holiday?(date)
    when :follows_school_calendar
      !@holidays.holiday?(date)
    end
  end

  def match_weekday?(date)
    open_close_times.any? { |open_close_time| matches_weekday?(date, open_close_time) }
  end

  def matches_weekday?(date, open_close_time)
    case open_close_time[:day_of_week]
    when :weekdays
      date.wday.between?(1, 5)
    when :weekends
      date.wday.zero? || date.wday == 6
    when :everyday
      true
    when :monday
      date.wday == 1
    when :tuesday
      date.wday == 2
    when :wednesday
      date.wday == 3
    when :thursday
      date.wday == 4
    when :friday
      date.wday == 5
    when :saturday
      date.wday == 6
    when :sunday
      date.wday.zero?
    end
  end

  def matches_start_end_date?(date)
    (@open_close_time[:start_date].nil? || date >= @open_close_time[:start_date]) &&
      (@open_close_time[:end_date].nil? || date <= @open_close_time[:end_date])
  end

  def open_close_times
    @open_close_time.select { |time_n, _config| self.class.open_time_keys.include?(time_n) }.values
  end
end
