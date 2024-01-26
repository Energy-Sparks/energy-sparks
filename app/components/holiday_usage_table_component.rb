class HolidayUsageTableComponent < ViewComponent::Base
  include AdvicePageHelper

  # holiday usage is a Hash of school_period => OpenStruct
  # as returned by HolidayUsageCalculationService.school_holiday_calendar_comparison
  def initialize(id: 'holiday-usage-table', holiday_usage:, analysis_dates:)
    @id = id
    @holiday_usage = holiday_usage
    @analysis_dates = analysis_dates
  end

  def usage(holiday)
    @holiday_usage[holiday]
  end

  def school_periods
    sort_school_periods(@holiday_usage.keys)
  end

  #sort an array of SchoolPeriod objects
  def sort_school_periods(periods)
    periods.sort { |a, b| a.start_date <=> b.start_date }
  end

  def can_compare_holiday_usage?(holiday, holiday_usage)
    return false unless holiday_usage.usage.present?
    return false unless holiday_usage.previous_holiday_usage.present?
    Time.zone.today > holiday.end_date
  end

  def last_period
    school_periods.last
  end

  def within_school_period?(school_period)
    @analysis_dates.end_date > school_period.start_date && @analysis_dates.end_date < school_period.end_date
  end

  def average_daily_usage(usage, school_period)
    return usage.kwh / (school_period.end_date - school_period.start_date)
  end

  def format_value(value, unit = :kwh)
    format_unit(value, unit, true, :target)
  end
end
