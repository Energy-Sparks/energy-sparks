module NewSimulatorChartConfig
  extend ActiveSupport::Concern

  CHART_CONFIG_FOR_SCHOOL = {
    name: 'Intraday (Comparison 6 months apart)',
    chart1_type: :line,
    series_breakdown: :none,
    timescale: [{ schoolweek: 0 }],
    x_axis: :intraday,
    meter_definition: :allelectricity,
    filter: { daytype: :occupied },
    yaxis_units: :kw,
    yaxis_scaling: :none
  }.freeze

  CHART_CONFIG_FOR_SIMULATOR = {
    name: 'Intraday (Comparison 6 months apart)',
    chart1_type: :line,
    series_breakdown: :none,
    timescale: [{ schoolweek: 0 }],
    x_axis: :intraday,
    meter_definition: :electricity_simulator,
    filter: { daytype: :occupied },
    yaxis_units: :kw,
    yaxis_scaling: :none
  }.freeze

  private

  def chart_config_for_school
    CHART_CONFIG_FOR_SCHOOL.deep_dup
  end

  def chart_config_for_simulator
    CHART_CONFIG_FOR_SIMULATOR.deep_dup
  end
end
