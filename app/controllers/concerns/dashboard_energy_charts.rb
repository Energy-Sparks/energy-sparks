module DashboardEnergyCharts
  extend ActiveSupport::Concern

  def setup_energy_overview_charts(configuration)
    return {} unless configuration

    {
      electricity: { chart: :management_dashboard_group_by_week_electricity, units: :£ },
      gas: { chart: :management_dashboard_group_by_week_gas, units: :£ },
      storage_heater: { chart: :management_dashboard_group_by_week_storage_heater, units: :£ },
      solar: { chart: :management_dashboard_group_by_month_solar_pv, units: :kwh }
    }.select { |_energy, chart_config| configuration.dashboard_charts.include?(chart_config[:chart].to_s) }
  end
end
