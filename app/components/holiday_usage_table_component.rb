class HolidayUsageTableComponent < ViewComponent::Base
  include AdvicePageHelper

  # holiday usage is a Hash of school_period => OpenStruct
  # as returned by HolidayUsageCalculationService.school_holiday_calendar_comparison
  def initialize(id: 'holiday-usage-table', holiday_usage:, analysis_dates:)
    @id = id
    @holiday_usage = holiday_usage
    @analysis_dates = analysis_dates
  end

  # Return usage summary for a specific holiday period
  # {usage: CombinedUsageMetric,
  #  previous_holiday_usage: CombinedUsageMetric,
  #  previous_holiday: SchoolPeriod}
  def usage(holiday)
    @holiday_usage[holiday]
  end

  # Return period for previous holiday
  def previous_holiday_usage(holiday)
    usage(holiday).previous_holiday
  end

  #Return the holidays (SchoolPeriod) in date order
  def school_periods
    @holiday_usage.keys.sort_by(&:start_date)
  end

  def can_compare_holiday_usage?(holiday, holiday_usage)
    return false unless holiday_usage.usage.present?
    return false unless holiday_usage.previous_holiday_usage.present?
    Time.zone.today > holiday.end_date
  end

  def within_school_period?(school_period)
    @analysis_dates.end_date > school_period.start_date && @analysis_dates.end_date < school_period.end_date
  end

  # Return the average daily usage in the previous holiday period
  def average_daily_usage_previous_holiday(holiday)
    average_daily_usage(usage(holiday).previous_holiday_usage, holiday)
  end

  # Return the average daily usage in kWh for a SchoolPeriod
  def average_daily_usage(usage, school_period)
    return usage.kwh / (school_period.end_date - school_period.start_date)
  end

  def format_value(value, unit = :kwh)
    format_unit(value, unit, true, :target)
  end
end
