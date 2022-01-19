module Management
  class SchoolsController < ApplicationController
    load_and_authorize_resource

    include SchoolAggregation
    include DashboardEnergyCharts
    include DashboardAlerts
    include DashboardTimeline
    include DashboardPriorities
    include AnalysisPages
    include SchoolProgress

    before_action :check_aggregated_school_in_cache

    def show
      authorize! :show_management_dash, @school
      @show_data_enabled_features = show_data_enabled_features?
      setup_default_features
      setup_data_enabled_features if @show_data_enabled_features
      if params[:report] && @show_data_enabled_features
        render :report, layout: 'report'
      else
        render :show
      end
    end

    private

    def setup_default_features
      @observations = setup_timeline(@school.observations)
      @add_contacts = site_settings.message_for_no_contacts && @school.contacts.empty? && can?(:manage, Contact)
      @add_pupils = site_settings.message_for_no_pupil_accounts && @school.users.pupil.empty? && can?(:manage_users, @school)
      @prompt_training = !@show_data_enabled_features || current_user.confirmed_at < 60.days.ago
      @prompt_for_bill = @school.bill_requested && can?(:index, ConsentDocument)
    end

    def setup_data_enabled_features
      @dashboard_alerts = setup_alerts(@school.latest_dashboard_alerts.management_dashboard, :management_dashboard_title)
      @management_priorities = setup_priorities(@school.latest_management_priorities, limit: site_settings.management_priorities_dashboard_limit)
      @overview_charts = setup_energy_overview_charts(@school.configuration)
      if EnergySparks::FeatureFlags.active?(:use_management_data)
        @overview_data = Schools::ManagementTableService.new(@school).management_data
      else
        @overview_table = Schools::ManagementTableService.new(@school).management_table
      end
      @progress_summary = progress_service.progress_summary
      @co2_pages = setup_co2_pages(@school.latest_analysis_pages)
      @add_targets = prompt_for_target?
      @review_targets = prompt_to_review_target?
      @recent_audit = Audits::AuditService.new(@school).recent_audit
    end
  end
end
