require_relative 'alert_out_of_hours_electricity_usage'

class AlertOutOfHoursElectricityUsagePreviousYear < AlertOutOfHoursElectricityUsage
  def enough_data
    days_amr_data >= 364 * 2 ? :enough : :not_enough
  end

  def out_of_hours_energy_consumption(data_type)
    chart = ChartManager.new(@school)
    chart.run_standard_chart(breakdown_charts[data_type], {timescale: {year: -1}}, true)
  end
end
