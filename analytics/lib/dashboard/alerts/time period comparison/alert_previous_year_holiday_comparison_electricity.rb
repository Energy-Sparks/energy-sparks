require_relative './alert_period_comparison_base.rb'

class AlertPreviousYearHolidayComparisonElectricity < AlertHolidayComparisonBase

  def initialize(school, type = :electricitypreviousyearholidaycomparison)
    super(school, type)
  end

  def comparison_chart
    :alert_group_by_week_electricity_14_months
  end

  def fuel_type; :electricity end

  def self.template_variables
    specific = {'Change between this holiday and the same holiday last year' => dynamic_template_variables(:electricity)}
    specific.merge(superclass.template_variables)
  end

  def reporting_period
    :same_holidays
  end

  protected

  def max_days_out_of_date_while_still_relevant
    60
  end

  def period_name(period)
    year = period.start_date.year == period.end_date.year ? period.start_date.year.to_s : ( period.start_date.year.to_s + '/' + period.end_date.year.to_s)
    I18n.t("analytics.holiday_year", holiday: I18nHelper.holiday(period.type), year: year)
  end

  def last_two_periods(asof_date)
    date_with_margin_for_enough_data = asof_date - minimum_days_for_period
    current_holiday = @school.holidays.find_previous_or_current_holiday(date_with_margin_for_enough_data, 100, MINIMUM_WEEKDAYS_DATA_FOR_RELEVANT_PERIOD)
    #not enough data checks in base class will stop alert being processed
    return [nil, nil] if current_holiday.nil?
    same_holiday_previous_year = @school.holidays.same_holiday_previous_year(current_holiday)
    current_holiday = truncate_period_to_available_meter_data(current_holiday)
    [current_holiday, same_holiday_previous_year]
  end
end
