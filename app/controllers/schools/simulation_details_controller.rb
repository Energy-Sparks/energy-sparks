require 'dashboard'

class Schools::SimulationDetailsController < Schools::SimulationsController
  include SchoolAggregation

  before_action :authorise_school
  before_action :set_simulation, only: :show

private

  def chart_definitions
    DashboardConfiguration::DASHBOARD_PAGE_GROUPS[:simulator_detail][:charts]
  end
end
