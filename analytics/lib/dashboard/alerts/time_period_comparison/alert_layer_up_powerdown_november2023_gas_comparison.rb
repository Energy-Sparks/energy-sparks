require_relative 'alert_arbitrary_period_comparison_gas_base'
require_relative 'alert_arbitrary_period_comparison_mixin'
require_relative 'alert_layer_up_powerdown_november2023_basic_config_mix_in'

class AlertLayerUpPowerdownNovember2023GasComparison < AlertArbitraryPeriodComparisonGasBase
  include ArbitraryPeriodComparisonMixIn
  include AlertLayerUpPowerdownNovember2023BasicConfigMixIn

  def comparison_configuration
    {
      comparison_chart:       :layerup_powerdown_november_2023_gas_comparison_alert
    }.merge(basic_configuration)
  end
end
