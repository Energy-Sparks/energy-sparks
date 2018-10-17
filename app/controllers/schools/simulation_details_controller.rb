class Schools::SimulationDetailsController < Schools::SimulationsController
private

  def set_show_charts
    @charts = DashboardConfiguration::DASHBOARD_PAGE_GROUPS[:simulator_detail][:charts]
  end
end
