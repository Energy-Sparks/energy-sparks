# frozen_string_literal: true

require_relative 'alert_storage_heater_mixin'
require_relative '../gas/boiler control/alert_thermostatic_control'

class AlertStorageHeaterThermostatic < AlertThermostaticControl
  include AlertGasToStorageHeaterSubstitutionMixIn
  include ElectricityCostCo2Mixin

  def initialize(school)
    super(school, :storage_heater_thermostatic)
    @relevance = @school.storage_heaters? ? :relevant : :never_relevant
  end

  def thermostatic_chart
    :storage_heater_thermostatic
  end
end
