require_relative '../gas/boiler_control/alert_heating_off'
require_relative './alert_storage_heater_mixin'
require_relative '../electricity/electricity_cost_co2_mixin'

class AlertTurnHeatingOffStorageHeaters < AlertTurnHeatingOff
  include AlertGasToStorageHeaterSubstitutionMixIn
  include ElectricityCostCo2Mixin
  def initialize(school)
    super(school, :storage_heater_heating_days)
    @relevance = @school.storage_heaters? ? :relevant : :never_relevant
    set_relevance
  end
end
