require_relative './alert_period_comparison_base.rb'
require_relative './alert_period_comparison_temperature_adjustment_mixin.rb'

class AlertPreviousHolidayComparisonGas < AlertPreviousHolidayComparisonElectricity
  include AlertPeriodComparisonTemperatureAdjustmentMixin
  include AlertPeriodComparisonGasMixin

  def self.x_template_variables
    specific = { 'Adjusted gas school week specific (debugging)' => AlertPeriodComparisonGasMixin.holiday_adjusted_gas_variables }
    specific['Change in between last 2 holidays'] = AlertPeriodComparisonBase.dynamic_template_variables(:gas)
    specific['Unadjusted previous period consumption'] = AlertPeriodComparisonTemperatureAdjustmentMixin.unadjusted_template_variables
    specific.merge(superclass.template_variables)
  end

  def self.template_variables
    AlertPeriodComparisonGasMixin.template_variables.merge(superclass.template_variables)
  end

  def initialize(school, type = :gaspreviousholidaycomparison)
    super(school, type)
  end

  def comparison_chart
    :alert_group_by_week_gas_4_months
  end
end
