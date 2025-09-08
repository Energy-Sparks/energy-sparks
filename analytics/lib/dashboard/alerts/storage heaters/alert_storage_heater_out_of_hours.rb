require_relative './alert_storage_heater_mixin.rb'

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

class AlertOutOfHoursStorageHeaterUsagePreviousYear < AlertStorageHeaterOutOfHours
  def enough_data
    days_amr_data >= 364 * 2 ? :enough : :not_enough
  end

  def out_of_hours_energy_consumption(data_type)
    chart = ChartManager.new(@school)
    chart.run_standard_chart(breakdown_charts[data_type], {timescale: {year: -1}}, true)
  end
end
