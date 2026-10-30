require_relative 'alert_arbitrary_period_comparison_electricity_base'
require_relative 'arbitrary_period_comparison_mix_in'
require_relative 'alert_autumn_term20212022_comparison_mix_in'

class AlertAutumnTerm20212022ElectricityComparison < AlertArbitraryPeriodComparisonElectricityBase
  include ArbitraryPeriodComparisonMixIn
  include AlertAutumnTerm20212022ComparisonMixIn

  def comparison_configuration
    {
      comparison_chart:       :autumn_term_2022_electricity_comparison_alert
    }.merge(basic_configuration)
  end
end
