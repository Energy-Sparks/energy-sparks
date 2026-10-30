# frozen_string_literal: true

require_relative 'alert_storage_heater_mixin'
require_relative '../time_period_comparison/alert_schoolweek_comparison_gas'

class AlertSchoolWeekComparisonStorageHeater < AlertSchoolWeekComparisonGas
  include AlertGasToStorageHeaterSubstitutionMixIn
  include ElectricityCostCo2Mixin

  def initialize(school)
    super(school, :storage_heaters)
    @relevance = @school.storage_heaters? ? :relevant : :never_relevant
  end

  def adjusted_temperature_comparison_chart
    :schoolweek_alert_2_week_comparison_for_internal_calculation_storage_heater_adjusted
  end

  def unadjusted_temperature_comparison_chart
    :schoolweek_alert_2_week_comparison_for_internal_calculation_storage_heater_unadjusted
  end

  def heating_type
    I18n.t('analytics.common.storage_heaters')
  end

  def aggregate_meter
    @school.storage_heater_meter
  end

  def needs_storage_heater_data?
    true
  end
end
