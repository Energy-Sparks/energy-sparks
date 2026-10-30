require_relative 'alert_arbitrary_period_comparison_electricity_base'
require_relative 'alert_arbitrary_period_comparison_mixin'
require_relative 'alert_heat_saver2024_basic_config_mix_in'

class AlertHeatSaver2024ElectricityComparison < AlertArbitraryPeriodComparisonElectricityBase
  include ArbitraryPeriodComparisonMixIn
  include AlertHeatSaver2024BasicConfigMixIn

  def comparison_configuration
    {
      comparison_chart:       :heat_saver_march_2024_electricity_comparison_alert
    }.merge(basic_configuration)
  end
end
