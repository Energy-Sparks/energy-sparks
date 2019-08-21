module DashboardEnergyCharts
  extend ActiveSupport::Concern

  def setup_charts(school_configuration)
    charts = {}

    return charts if school_configuration.nil?

    if school_configuration.electricity
      charts[:electricity] = :teachers_landing_page_electricity
    end

    gas_dashboard_chart_type = school_configuration.gas_dashboard_chart_type.to_sym

    if gas_dashboard_chart_type != Schools::Configuration::NO_CHART
      charts[:gas] = gas_dashboard_chart_type
    end

    charts
  end
end
