module Management
  class SchoolsController < ApplicationController
    load_and_authorize_resource

    include SchoolAggregation
    include DashboardEnergyCharts
    include DashboardAlerts
    include DashboardTimeline

    before_action :check_aggregated_school_in_cache

    def show
      authorize! :show_management_dash, @school
      @charts = setup_charts(@school.configuration)
      @dashboard_alerts = setup_alerts(@school.latest_dashboard_alerts.management_dashboard, :management_dashboard_title)
      @observations = setup_timeline(@school.observations)
    end
  end
end
