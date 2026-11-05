require_relative 'alert_arbitrary_period_comparison_base'
require_relative 'alert_period_comparison_temperature_adjustment_mixin'
require_relative 'alert_period_comparison_gas_mixin'

class AlertArbitraryPeriodComparisonGasBase < AlertArbitraryPeriodComparisonBase
  include AlertPeriodComparisonTemperatureAdjustmentMixin
  include AlertPeriodComparisonGasMixin

  def self.template_variables
    AlertPeriodComparisonGasMixin.template_variables.merge(superclass.template_variables)
  end

  def fuel_type; :gas end
end
