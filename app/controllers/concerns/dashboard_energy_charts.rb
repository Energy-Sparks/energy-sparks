module DashboardEnergyCharts
  extend ActiveSupport::Concern

  def setup_charts
    @charts = {}

    if @school.configuration.electricity
      @charts[:electricity] = :teachers_landing_page_electricity
    end

    if @school.configuration.gas_dashboard_chart_type.to_sym != Schools::Configuration::NO_CHART
      @charts[:gas] = @school.configuration.gas_dashboard_chart_type.to_sym
    end
  end
end
