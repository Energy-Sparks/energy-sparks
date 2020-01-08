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
      @overview_charts = setup_energy_overview_charts
      @overview_table = setup_management_table
      @add_contacts = site_settings.message_for_no_contacts && @school.contacts.empty? && can?(:manage, Contact)
      @add_pupils = site_settings.message_for_no_pupil_accounts && @school.users.pupil.empty? && can?(:manage_users, @school)
    end


    private

    def setup_energy_overview_charts
      return {} unless @school.configuration
      {
        electricity: { chart: [:analysis_charts, :electricity_detail, :group_by_week_electricity], units: :£ },
        gas: { chart: [:analysis_charts, :gas_detail, :group_by_week_gas], units: :£ },
        storage_heater: { chart: [:analysis_charts, :storage_heaters, :storage_heater_group_by_week], units: :£ },
        solar: { chart: [:analysis_charts, :solar_pv, :solar_pv_group_by_month], units: :kwh }
      }.select {|_energy, chart_config| @school.configuration.can_show_analysis_chart?(*chart_config[:chart])}
    end

    def setup_management_table
      @school.latest_management_dashboard_tables.first
    end
  end
end
