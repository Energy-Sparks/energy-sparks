module DashboardEnergyCharts
  extend ActiveSupport::Concern

  def setup_charts(school_configuration)
    charts = {}

    return charts if school_configuration.nil?

    if school_configuration.has_electricity
      charts[:electricity] = { chart_type: :teachers_landing_page_electricity, explore: true }
    end

    gas_dashboard_chart_type = school_configuration.gas_dashboard_chart_type.to_sym
    if gas_dashboard_chart_type != Schools::Configuration::NO_GAS_CHART
      charts[:gas] = { chart_type: gas_dashboard_chart_type, explore: true }
    end

    storage_heater_dashboard_chart_type = school_configuration.storage_heater_dashboard_chart_type.to_sym
    if storage_heater_dashboard_chart_type != Schools::Configuration::NO_STORAGE_HEATER_CHART
      charts[:storage_heaters] = { chart_type: storage_heater_dashboard_chart_type, explore: false }
    end

    charts
  end
end
