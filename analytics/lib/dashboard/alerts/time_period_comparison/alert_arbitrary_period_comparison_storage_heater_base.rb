require_relative 'alert_arbitrary_period_comparison_base'
require_relative 'alert_period_comparison_temperature_adjustment_mixin'
require_relative 'alert_period_comparison_gas_mixin'
require_relative '../storage_heaters/alert_storage_heater_mixin'
require_relative '../electricity/electricity_cost_co2_mixin'

class AlertArbitraryPeriodComparisonStorageHeaterBase < AlertArbitraryPeriodComparisonBase
  include AlertPeriodComparisonTemperatureAdjustmentMixin
  include AlertPeriodComparisonGasMixin
  include AlertGasToStorageHeaterSubstitutionMixIn
  include ElectricityCostCo2Mixin

  def self.template_variables
    AlertPeriodComparisonGasMixin.template_variables.merge(superclass.template_variables)
  end

  def fuel_type; :electricity end
end
