require_relative 'alert_arbitrary_period_comparison_gas_base'
require_relative 'alert_arbitrary_period_comparison_mixin'
require_relative 'alert_autumn_term20212022_comparison_mix_in'

class AlertAutumnTerm20212022GasComparison < AlertArbitraryPeriodComparisonGasBase
  include ArbitraryPeriodComparisonMixIn
  include AlertAutumnTerm20212022ComparisonMixIn

  def comparison_configuration
    {
      comparison_chart:       :autumn_term_2022_gas_comparison_alert
    }.merge(basic_configuration)
  end
end
