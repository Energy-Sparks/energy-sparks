#======================== Gas: Out of hours usage =============================
require_relative '../common/alert_out_of_hours_base_usage.rb'

class AlertOutOfHoursGasUsage < AlertOutOfHoursBaseUsage
  attr_reader :daytype_breakdown_table
  def initialize(
    school,
    fuel = 'gas',
    type = :gasoutofhours,
    meter_defn_not_used = :allheat,
    good_out_of_hours_use_percent = BenchmarkMetrics::EXEMPLAR_OUT_OF_HOURS_USE_PERCENT_GAS,
    bad_out_of_hours_use_percent = BenchmarkMetrics::BENCHMARK_OUT_OF_HOURS_USE_PERCENT_GAS
  )
    super(
      school,
      fuel,
      type,
      meter_defn_not_used,
      good_out_of_hours_use_percent,
      bad_out_of_hours_use_percent
    )
  end

  def aggregate_meter
    @school.aggregated_heat_meters
  end

  def maximum_alert_date
    aggregate_meter.amr_data.end_date
  end

  def needs_electricity_data?
    false
  end

  def breakdown_chart
    :alert_daytype_breakdown_gas
  end

  def breakdown_charts
    {
      kwh:      :alert_daytype_breakdown_gas_kwh,
      co2:      :alert_daytype_breakdown_gas_co2,
      £:        :alert_daytype_breakdown_gas_£,
      £current: :alert_daytype_breakdown_gas_£current
    }
  end

  def group_by_week_day_type_chart
    :alert_group_by_week_gas
  end

  TEMPLATE_VARIABLES = {
    breakdown_chart: {
      description: 'Pie chart showing out of hour gas consumption breakdown (school day, school day outside hours, weekends, holidays), also used for table generation',
      units:  :chart
    },
    group_by_week_day_type_chart: {
      description: 'Weekly chart showing out of hour gas consumption breakdown (school day, school day outside hours, weekends, holidays), for last year',
      units:  :chart
    }
  }

  def self.template_variables
    specific = {
      'Gas specific out of hours consumption' => TEMPLATE_VARIABLES,
      'Out of hours energy consumption' => superclass.static_template_variables(:gas)
    }
    specific.merge(superclass.template_variables)
  end

  def tariff_deprecated
    # BenchmarkMetrics::GAS_PRICE
  end

  def co2_intensity_per_kwh
    EnergyEquivalences::UK_GAS_CO2_KG_KWH
  end
end

class AlertOutOfHoursGasUsagePreviousYear < AlertOutOfHoursGasUsage
  def enough_data
    days_amr_data >= 364 * 2 ? :enough : :not_enough
  end

  def out_of_hours_energy_consumption(data_type)
    chart = ChartManager.new(@school)
    chart.run_standard_chart(breakdown_charts[data_type], {timescale: {year: -1}}, true)
  end
end
