require_relative '../gas/alert_out_of_hours_gas_usage'
require_relative './alert_storage_heater_mixin'
require_relative '../electricity/electricity_cost_co2_mixin'

class AlertStorageHeaterOutOfHours < AlertOutOfHoursGasUsage
  include AlertGasToStorageHeaterSubstitutionMixIn
  include ElectricityCostCo2Mixin
  def initialize(school)
    super(
      school,
      'electricity',
      :storageheateroutofhours,
      :allstorageheater,
      BenchmarkMetrics::EXEMPLAR_OUT_OF_HOURS_USE_PERCENT_STORAGE_HEATER,
      BenchmarkMetrics::BENCHMARK_OUT_OF_HOURS_USE_PERCENT_STORAGE_HEATER
    )
    @relevance = @school.storage_heaters? ? :relevant : :never_relevant
  end

  def breakdown_chart
    :alert_daytype_breakdown_storage_heater
  end

  def breakdown_charts
    {
      kwh:      :alert_daytype_breakdown_storage_heater_kwh,
      co2:      :alert_daytype_breakdown_storage_heater_co2,
      £:        :alert_daytype_breakdown_storage_heater_£,
      £current: :alert_daytype_breakdown_storage_heater_£current
    }
  end

  def group_by_week_day_type_chart
    :alert_group_by_week_storage_heaters
  end

  def school_day_closed_key
    Series::DayType::STORAGE_HEATER_CHARGE
  end
end
