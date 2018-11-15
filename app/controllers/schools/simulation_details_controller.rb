# Warning - this pulls in statsample which seems to do something
# to array#sum - https://github.com/clbustos/statsample/issues/45
require 'dashboard'

class Schools::SimulationDetailsController < Schools::SimulationsController
private

  def set_show_charts
    @charts = DashboardConfiguration::DASHBOARD_PAGE_GROUPS[:simulator_detail][:charts]
  end
end
