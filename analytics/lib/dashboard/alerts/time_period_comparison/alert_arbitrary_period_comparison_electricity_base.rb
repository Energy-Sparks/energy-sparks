require_relative 'alert_arbitrary_period_comparison_base'

class AlertArbitraryPeriodComparisonElectricityBase < AlertArbitraryPeriodComparisonBase
  def fuel_type; :electricity end

  def self.template_variables
    specific = { 'Change in between last 2 periods' => dynamic_template_variables(:electricity) }
    specific.merge(superclass.template_variables)
  end
end
