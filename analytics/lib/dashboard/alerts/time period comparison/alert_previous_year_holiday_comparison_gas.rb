require_relative './alert_period_comparison_base.rb'
require_relative './alert_previous_year_holiday_comparison_electricity.rb'
require_relative './alert_arbitrary_period_comparison_mixin.rb'
require_relative './alert_previous_year_holiday_comparison_gas.rb'
require_relative './alert_period_comparison_temperature_adjustment_mixin.rb'
require_relative './alert_period_comparison_gas_mixin.rb'

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
