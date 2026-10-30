require_relative '../gas/boiler_control/alert_seasonal_heating_school_days'
require_relative './alert_gas_to_storage_heater_substitution_mix_in'
require_relative '../electricity/electricity_cost_co2_mixin'

class AlertSeasonalHeatingSchoolDaysStorageHeaters < AlertSeasonalHeatingSchoolDays
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
