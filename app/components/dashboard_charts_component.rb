class DashboardChartsComponent < ApplicationComponent
  include DashboardEnergyCharts
  include ChartHelper

  attr_reader :school

  renders_one :title
  renders_one :intro

  def initialize(school:, **_kwargs)
    super
    @school = school
  end

  def render?
    charts&.any?
  end

  def charts
    @charts ||= setup_energy_overview_charts(@school.configuration)
  end

  def default_chart_config(chart_config)
    { y_axis_units: select_y_axis(@school, chart_config[:chart], chart_config[:units]) }
  end
end
