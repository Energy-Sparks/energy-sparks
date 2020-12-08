module DashboardEnergyCharts
  extend ActiveSupport::Concern

  def setup_charts(school_configuration)
    charts = {}

    return charts if school_configuration.nil?

    if school_configuration.has_solar_pv
      charts[:solar] = { chart_type: :teachers_landing_page_electricity }
    elsif school_configuration.has_electricity
      charts[:electricity] = { chart_type: :teachers_landing_page_electricity }
    end

    gas_dashboard_chart_type = school_configuration.gas_dashboard_chart_type.to_sym
    if gas_dashboard_chart_type != Schools::Configuration::NO_GAS_CHART
      charts[:gas] = { chart_type: gas_dashboard_chart_type }
    end

    storage_heater_dashboard_chart_type = school_configuration.storage_heater_dashboard_chart_type.to_sym
    if storage_heater_dashboard_chart_type != Schools::Configuration::NO_STORAGE_HEATER_CHART
      charts[:storage_heaters] = { chart_type: storage_heater_dashboard_chart_type }
    end

    charts
  end

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
