require_relative '../gas/alert_gas_long_term_trend'
require_relative 'alert_gas_to_storage_heater_substitution_mix_in'
require_relative '../electricity/electricity_cost_co2_mixin'

class AlertStorageHeatersLongTermTrend < AlertGasLongTermTrend
  include AlertGasToStorageHeaterSubstitutionMixIn
  include ElectricityCostCo2Mixin
  def initialize(school)
    super(school, :storage_heater_heating_days)
    @relevance = @school.storage_heaters? ? :relevant : :never_relevant
  end

  def self.template_variables
    specific = { 'Storage heaters long term trend' => long_term_variables('storage heater')}
    specific.merge(self.superclass.template_variables)
  end

  def fuel_type
    :storage_heaters
  end

  protected def aggregate_meter
    @school.storage_heater_meter
  end
end
