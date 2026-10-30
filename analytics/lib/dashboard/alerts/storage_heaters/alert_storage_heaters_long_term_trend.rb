# frozen_string_literal: true

require_relative 'alert_storage_heater_mixin'
require_relative '../common/alert_long_term_trend'

class AlertStorageHeatersLongTermTrend < AlertGasLongTermTrend
  include AlertGasToStorageHeaterSubstitutionMixIn
  include ElectricityCostCo2Mixin

  def initialize(school)
    super(school, :storage_heater_heating_days)
    @relevance = @school.storage_heaters? ? :relevant : :never_relevant
  end

  def self.template_variables
    specific = { 'Storage heaters long term trend' => long_term_variables('storage heater') }
    specific.merge(superclass.template_variables)
  end

  def fuel_type
    :storage_heaters
  end

  protected

  def aggregate_meter
    @school.storage_heater_meter
  end
end
