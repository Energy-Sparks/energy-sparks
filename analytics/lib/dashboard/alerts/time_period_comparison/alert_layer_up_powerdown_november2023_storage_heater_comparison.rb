require_relative 'alert_arbitrary_period_comparison_storage_heater_base'
require_relative 'arbitrary_period_comparison_mix_in'
require_relative 'alert_layer_up_powerdown_november2023_basic_config_mix_in'

class AlertLayerUpPowerdownNovember2023StorageHeaterComparison < AlertArbitraryPeriodComparisonStorageHeaterBase
  include ArbitraryPeriodComparisonMixIn
  include AlertLayerUpPowerdownNovember2023BasicConfigMixIn

  def comparison_configuration
    {
      comparison_chart:       :layerup_powerdown_november_2023_storage_heater_comparison_alert
    }.merge(basic_configuration)
  end
end
