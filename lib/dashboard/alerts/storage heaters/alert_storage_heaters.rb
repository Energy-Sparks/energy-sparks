require_relative './alert_storage_heater_mixin.rb'
require_relative './../gas/boiler control/alert_thermostatic_control.rb'
require_relative './../gas/boiler control/alert_school_heating_days.rb'
require_relative './../gas/boiler control/alert_heating_day_base.rb'
#require_relative './../gas/boiler control/alert_gas_heating_hot_water_on_during_holiday.rb'
require_relative './../gas/boiler control/alert_seasonal_heating_schooldays.rb'
require_relative './../gas/boiler control/alert_heating_off.rb'
require_relative './../common/alert_targets.rb'
# require_all 'lib/dashboard/alerts/time period comparison/'
require_relative './../time period comparison/alert_schoolweek_comparison_gas.rb'
require_relative './../time period comparison/alert_previous_year_holiday_comparison_gas.rb'

class AlertStorageHeaterAnnualVersusBenchmark < AlertGasAnnualVersusBenchmark
  include AlertGasToStorageHeaterSubstitutionMixIn
  include ElectricityCostCo2Mixin
  def initialize(school)
    super(school, :storage_heater_annual_benchmark)
    @relevance = @school.storage_heaters? ? :relevant : :never_relevant
  end

  private def dd_adj(asof_date)
    BenchmarkMetrics.normalise_degree_days(@school.temperatures, @school.holidays, :electricity, asof_date)
  end
end

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

class AlertTurnHeatingOffStorageHeaters < AlertTurnHeatingOff
  include AlertGasToStorageHeaterSubstitutionMixIn
  include ElectricityCostCo2Mixin
  def initialize(school)
    super(school, :storage_heater_heating_days)
    @relevance = @school.storage_heaters? ? :relevant : :never_relevant
    set_relevance
  end
end

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

class AlertStorageHeaterTargetAnnual < AlertGasTargetAnnual
  include AlertGasToStorageHeaterSubstitutionMixIn
  include ElectricityCostCo2Mixin
  def self.template_variables
    specific = { 'Storage heaters targetting and tracking' => long_term_variables('storage heaters')}
    specific.merge(self.superclass.template_variables)
  end

  def fuel_type
    :storage_heaters
  end

  def aggregate_meter
    @school.storage_heater_meter
  end

  def aggregate_target_meter
    @school.target_school.storage_heater_meter
  end
end

class AlertStorageHeaterTarget4Week < AlertStorageHeaterTargetAnnual
  def rating_target_percent
    last_4_weeks_percent_of_target
  end
end

class AlertStorageHeaterTarget1Week < AlertStorageHeaterTargetAnnual
  def rating_target_percent
    last_week_percent_of_target
  end
end

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
    I18n.t("analytics.common.storage_heaters")
  end

  def aggregate_meter
    @school.storage_heater_meter
  end

  def needs_storage_heater_data?
    true
  end
end

class AlertPreviousYearHolidayComparisonStorageHeater < AlertPreviousYearHolidayComparisonGas
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
    I18n.t("analytics.common.storage_heaters")
  end

  def aggregate_meter
    @school.storage_heater_meter
  end

  def needs_storage_heater_data?
    true
  end
end
