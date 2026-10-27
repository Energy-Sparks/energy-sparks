# frozen_string_literal: true

# manages school open and close times
class OpenCloseTimes
  class UnknownFrontEndType < StandardError; end
  attr_reader :open_times

  def initialize(open_times, holidays)
    @holidays = holidays
    @open_times = open_times
  end

  def usage(date)
    usages = Hash.new { |h, k| h[k] = [] }

    @open_times.each do |usage_time|
      usages[usage_time.type] += usage_time.time_ranges_for_week_day(date) if usage_time.matched_usage?(date)
    end

    usages
  end

  #Only used in test script
  def print_usages(date)
    puts date.strftime('%a %d %b %Y')
    ap usage(date)
  end

  #Create the OpenCloseTime instances from the internal hash structure and
  #return a new OpenCloseTimes object
  def self.create_open_close_times(open_close_time_attributes, holidays)
    open_close_time_config = open_close_time_attributes[:open_close_times] || self.class.default_school_open_close_times_config
    opening_times = open_close_time_config.map { |t| OpenCloseTime.new(t, holidays) }
    OpenCloseTimes.new(opening_times, holidays)
  end

  #Convert hash structure passed by application to a different hash structure
  #used internally
  def self.convert_frontend_times(school_times, community_times, holidays)
    st = convert_frontend_time(school_times)
    ct = convert_frontend_time(community_times)
    OpenCloseTimes.create_open_close_times({ open_close_times: st + ct }, holidays)
  end

  def self.convert_frontend_time(times)
    times.map do |time_period|
      convert_front_end_time_period(time_period)
    end
  end

  def self.convert_front_end_time_period(time_period)
    {
      type: convert_front_end_usage_type(time_period[:usage_type]),
      holiday_calendar: convert_front_end_calendar_type(time_period[:calendar_period]),
      time0: {
        day_of_week: convert_front_end_day(time_period[:day]),
        from: time_period[:opening_time],
        to: time_period[:closing_time]
      }
    }
  rescue StandardError => e
    puts e.message
    raise
  end

  def self.convert_front_end_usage_type(type)
    case type
    when :school_day
      :school_day_open
    when :community_use
      OpenCloseTime::COMMUNITY
    else
      raise UnknownFrontEndType, "Opening type #{type}"
    end
  end

  def self.convert_front_end_calendar_type(type)
    case type
    when :term_times
      :follows_school_calendar
    when :only_holidays
      :holidays_only
    when :all_year
      :no_holidays
    else
      raise UnknownFrontEndType, "Calendar period #{type}"
    end
  end

  def self.convert_front_end_day(type)
    raise UnknownFrontEndType, "Day type #{type}" unless OpenCloseTime.day_of_week_types.include?(type)

    type
  end

  def self.default_school_open_close_times_config
    [
      {
        type: :school_day_open,
        holiday_calendar: :follows_school_calendar,
        time0: { day_of_week: :weekdays, from: TimeOfDay.new(7, 0), to: TimeOfDay.new(16, 30) }
      }
    ]
  end

  def self.default_school_open_close_times(holidays)
    OpenCloseTimes.create_open_close_times.new({}, holidays)
  end

  def time_types
    [
      :school_day_open,
      OpenCloseTime.non_user_configurable_community_use_types.keys,
      @open_times.map(&:type)
    ].flatten.uniq
  end

  def community_usage?
    @community_usage ||= time_types.any? { |tt| OpenCloseTime.community_usage_types.include?(tt) }
  end

  def series_names
    @series_names ||= time_types.sort_by { |type| OpenCloseTime.community_use_types[type][:sort_order] }
  end

  def remainder_type(date)
    case @holidays.day_type(date)
    when :holiday
      :holiday
    when :weekend
      :weekend
    when :schoolday
      :school_day_closed
    end
  end
end
