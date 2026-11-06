require_relative 'alert_arbitrary_period_comparison_storage_heater_base'
require_relative 'arbitrary_period_comparison_mix_in'
require_relative 'alert_easter2023_shutdown_configuration_mixin'

class AlertEaster2023ShutdownStorageHeaterComparison < AlertArbitraryPeriodComparisonStorageHeaterBase
  include ArbitraryPeriodComparisonMixIn #adds in helpers
  include HolidayShutdownComparisonMixin #adds in some additional helpers
  include AlertEaster2023ShutdownConfigurationMixin #mixin the configuration

  #Method to access the configuration
  def comparison_configuration
    basic_configuration
  end
end
