class HolidayUsageTableComponent < ViewComponent::Base
  include AdvicePageHelper

  # holiday usage is a Hash of school_period => OpenStruct
  # { usage: CombinedUsageMetric,
  #   previous_holiday_usage: CombinedUsageMetric,
  #   previous_holiday: SchoolPeriod
  # }
  # as returned by HolidayUsageCalculationService.school_holiday_calendar_comparison
  def initialize(id: 'holiday-usage-table', holiday_usage:, analysis_dates:)
    @id = id
    @holiday_usage = holiday_usage
    @analysis_dates = analysis_dates
  end

  # Return usage metrics for a specific holiday period
  def holiday_usage(holiday)
    @holiday_usage[holiday].usage
  end

  # Return usage metrics for previous holiday
  def previous_holiday_usage(holiday)
    @holiday_usage[holiday].previous_holiday_usage
  end

  # Return period for previous holiday
  def previous_holiday_period(holiday)
    @holiday_usage[holiday].previous_holiday
  end

  #Return the holidays (SchoolPeriod) in date order
  def school_periods
    @holiday_usage.keys.sort_by(&:start_date)
  end

  def can_compare_holiday_usage?(holiday)
    return false unless holiday_usage(holiday).present?
    return false unless previous_holiday_usage(holiday).present?
    @analysis_dates.end_date >= holiday.end_date
  end

  def within_school_period?(school_period)
    @analysis_dates.end_date > school_period.start_date && @analysis_dates.end_date < school_period.end_date
  end

  # Return the average daily usage in kWh for a SchoolPeriod
  def average_daily_usage(usage, school_period)
    return usage.kwh / school_period.days
  end

  def format_value(value, unit = :kwh)
    format_unit(value, unit, true, :target)
  end

  def current_holiday_row(holiday)
    period = holiday
    usage = holiday_usage(holiday)
    unless period.nil? || usage.nil?
      average_daily_usage = average_daily_usage(usage, period)
    end
    yield "", holiday, usage, average_daily_usage
  end

  def previous_holiday_row(holiday)
    label = I18nHelper.holiday(holiday.type)
    period = previous_holiday_period(holiday)
    usage = previous_holiday_usage(holiday)
    unless period.nil? || usage.nil?
      average_daily_usage = average_daily_usage(usage, period)
    end
    yield label, period, usage, average_daily_usage
  end

  def comparison_row(holiday)
    return false unless can_compare_holiday_usage?(holiday)
    holiday_usage = holiday_usage(holiday)
    previous_holiday_usage = previous_holiday_usage(holiday)
    previous_holiday_period = previous_holiday_period(holiday)
    yield "", holiday, holiday_usage, previous_holiday_period, previous_holiday_usage if block_given?
    true
  end
end
