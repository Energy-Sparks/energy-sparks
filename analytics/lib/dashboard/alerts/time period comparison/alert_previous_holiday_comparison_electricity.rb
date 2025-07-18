require_relative './alert_period_comparison_base.rb'

class AlertPreviousHolidayComparisonElectricity < AlertHolidayComparisonBase
  def initialize(school, type = :electricitypreviousholidaycomparison)
    super(school, type)
  end

  def comparison_chart
    :alert_group_by_week_electricity_4_months
  end

  def fuel_type; :electricity end

  def self.template_variables
    specific = { 'Change in between last 2 holidays' => dynamic_template_variables(:electricity) }
    specific.merge(superclass.template_variables)
  end

  def reporting_period
    :last_2_holidays
  end

  protected

  def max_days_out_of_date_while_still_relevant
    60
  end

  def last_two_periods(asof_date)
    date_with_margin_for_enough_data = asof_date - minimum_days_for_period
    current_holiday = @school.holidays.find_previous_or_current_holiday(date_with_margin_for_enough_data, 100, MINIMUM_WEEKDAYS_DATA_FOR_RELEVANT_PERIOD)
    #not enough data checks in base class will stop alert being processed
    return [nil, nil] if current_holiday.nil?
    previous_holiday = @school.holidays.find_previous_holiday_to_current(current_holiday, 1, MINIMUM_WEEKDAYS_DATA_FOR_RELEVANT_PERIOD)
    current_holiday = truncate_period_to_available_meter_data(current_holiday)
    [current_holiday, previous_holiday]
  end
end
