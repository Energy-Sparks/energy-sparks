module Management
  class SchoolsController < ApplicationController
    load_and_authorize_resource

    include SchoolAggregation
    include DashboardEnergyCharts
    include DashboardAlerts
    include DashboardTimeline
    include DashboardPriorities

    before_action :check_aggregated_school_in_cache

    def show
      authorize! :show_management_dash, @school
      @charts = setup_charts(@school.configuration)
      @dashboard_alerts = setup_alerts(@school.latest_dashboard_alerts.management_dashboard, :management_dashboard_title)
      @observations = setup_timeline(@school.observations)
      @management_priorities = setup_priorities(@school.latest_management_priorities, limit: site_settings.management_priorities_dashboard_limit)
      @overview_charts = setup_energy_overview_charts(@school.configuration)
      @overview_table = setup_management_table
      @add_contacts = site_settings.message_for_no_contacts && @school.contacts.empty? && can?(:manage, Contact)
      @add_pupils = site_settings.message_for_no_pupil_accounts && @school.users.pupil.empty? && can?(:manage_users, @school)
      if params[:report]
        render :report, layout: 'report'
      else
        render :show
      end
    end


    private

    def setup_management_table
      @school.latest_management_dashboard_tables.first
    end
  end
end
