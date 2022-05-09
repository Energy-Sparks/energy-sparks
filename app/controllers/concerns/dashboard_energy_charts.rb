module DashboardEnergyCharts
  extend ActiveSupport::Concern

  def setup_energy_overview_charts(configuration)
    return {} unless configuration
    {
      electricity: { chart: [:analysis_charts, :electricity_detail, :management_dashboard_group_by_week_electricity], units: :£ },
      gas: { chart: [:analysis_charts, :gas_detail, :management_dashboard_group_by_week_gas], units: :£ },
      storage_heater: { chart: [:analysis_charts, :storage_heaters, :management_dashboard_group_by_week_storage_heater], units: :£ },
      solar: { chart: [:analysis_charts, :solar_pv, :management_dashboard_group_by_month_solar_pv], units: :kwh }
    }.select {|_energy, chart_config| configuration.can_show_analysis_chart?(*chart_config[:chart])}
  end
end
