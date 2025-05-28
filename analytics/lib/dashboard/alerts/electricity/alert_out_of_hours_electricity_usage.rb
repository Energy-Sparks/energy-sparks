#======================== Electricity: Out of hours usage =====================
require_relative '../common/alert_out_of_hours_base_usage.rb'
require_relative './electricity_cost_co2_mixin.rb'

class AlertOutOfHoursElectricityUsage < AlertOutOfHoursBaseUsage
  include ElectricityCostCo2Mixin
  attr_reader :daytype_breakdown_table
  def initialize(school)
    super(
      school,
      'electricity',
      :electricityoutofhours,
      :allelectricity,
      BenchmarkMetrics::EXEMPLAR_OUT_OF_HOURS_USE_PERCENT_ELECTRICITY,
      BenchmarkMetrics::BENCHMARK_OUT_OF_HOURS_USE_PERCENT_ELECTRICITY
    )
  end

  def aggregate_meter
    @school.aggregated_electricity_meters
  end

  def maximum_alert_date
    aggregate_meter.amr_data.end_date
  end

  def needs_gas_data?
    false
  end

  def breakdown_chart
    :alert_daytype_breakdown_electricity
  end

  def breakdown_charts
    {
      kwh:      :alert_daytype_breakdown_electricity_kwh,
      co2:      :alert_daytype_breakdown_electricity_co2,
      £:        :alert_daytype_breakdown_electricity_£,
      £current: :alert_daytype_breakdown_electricity_£current,
    }
  end

  def group_by_week_day_type_chart
    :alert_group_by_week_electricity
  end

  TEMPLATE_VARIABLES = {
    breakdown_chart: {
      description: 'Pie chart showing out of hour electricity consumption breakdown (school day, school day outside hours, weekends, holidays), also used for table generation',
      units:  :chart
    },
    group_by_week_day_type_chart: {
      description: 'Weekly chart showing out of hour electricity consumption breakdown (school day, school day outside hours, weekends, holidays), for last year',
      units:  :chart
    }
  }

  def self.template_variables
    specific = {
      'Electricity specific out of hours consumption' => TEMPLATE_VARIABLES,
      'Out of hours energy consumption' => superclass.static_template_variables(:electricity)
    }
    specific.merge(superclass.template_variables)
  end

  def tariff
    blended_electricity_£_per_kwh
  end

  def co2_intensity_per_kwh
    blended_co2_per_kwh
  end
end

class AlertOutOfHoursElectricityUsagePreviousYear < AlertOutOfHoursElectricityUsage
  def enough_data
    days_amr_data >= 364 * 2 ? :enough : :not_enough
  end

  def out_of_hours_energy_consumption(data_type)
    chart = ChartManager.new(@school)
    chart.run_standard_chart(breakdown_charts[data_type], {timescale: {year: -1}}, true)
  end
end
