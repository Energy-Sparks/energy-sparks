require_relative 'alert_previous_year_holiday_comparison_electricity'
require_relative 'arbitrary_period_comparison_mix_in'
require_relative 'alert_period_comparison_temperature_adjustment_mixin'
require_relative 'alert_period_comparison_gas_mixin'

class AlertPreviousYearHolidayComparisonGas < AlertPreviousYearHolidayComparisonElectricity
  include AlertPeriodComparisonTemperatureAdjustmentMixin
  include AlertPeriodComparisonGasMixin

  def self.template_variables
    AlertPeriodComparisonGasMixin.template_variables.merge(superclass.template_variables)
  end

  def initialize(school, type = :gaspreviousyearholidaycomparison)
    super(school, type)
  end

  def comparison_chart
    :alert_group_by_week_gas_14_months
  end

  def reporting_period
    :same_holidays
  end
end
