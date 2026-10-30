require_relative '../gas/boiler_control/alert_heating_on_school_days_deprecated'
require_relative './alert_gas_to_storage_heater_substitution_mix_in'
require_relative '../electricity/electricity_cost_co2_mixin'

#NOTE: this doesn't seem to be setup in the application, as its not registered
#in the database. Should it be removed?
#Was removed from live system around 2022-04-11 and replaced by above
class AlertHeatingOnSchoolDaysStorageHeatersDeprecated < AlertHeatingOnSchoolDaysDeprecated
  include AlertGasToStorageHeaterSubstitutionMixIn
  include ElectricityCostCo2Mixin
  def initialize(school)
    super(school, :storage_heater_heating_days)
    @relevance = @school.storage_heaters? ? :relevant : :never_relevant
  end

  def heating_on_off_chart
    :heating_on_by_week_with_breakdown_storage_heaters
  end
end
