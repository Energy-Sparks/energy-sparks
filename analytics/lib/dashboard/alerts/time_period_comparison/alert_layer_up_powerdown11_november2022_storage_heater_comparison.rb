require_relative 'alert_arbitrary_period_comparison_storage_heater_base'
require_relative 'alert_arbitrary_period_comparison_mixin'
require_relative 'alert_layer_up_powerdown11_november2022_basic_config_mix_in'

class AlertLayerUpPowerdown11November2022StorageHeaterComparison < AlertArbitraryPeriodComparisonStorageHeaterBase
  include ArbitraryPeriodComparisonMixIn
  include AlertLayerUpPowerdown11November2022BasicConfigMixIn

  def comparison_configuration
    {
      comparison_chart:       :layerup_powerdown_11_november_2022_storage_heater_comparison_alert
    }.merge(basic_configuration)
  end
end
