# frozen_string_literal: true

module Navigation
  class AdminDashboardComponent < BaseComponent
    def nav_sections
      [
        { name: 'My School Groups', path: admin_dashboard_school_groups_path(current_user),
          match_on_param: { param: 'group_type', value: nil } },
        { name: 'My Project Groups', path: admin_dashboard_school_groups_path(current_user, group_type: 'project') },
        { name: 'My Data Sources', path: admin_dashboard_data_sources_path(current_user) },
        { name: 'My Data Feeds', path: admin_dashboard_amr_data_feed_configs_path(current_user) },
        { name: 'My Issues', path: admin_dashboard_issues_path(current_user) }
      ]
    end

    def my_schools_section
      [
        { name: 'Onboarding', path: admin_dashboard_school_onboardings_path(current_user) },
        { name: 'Awaiting activation', path: admin_dashboard_activations_path(current_user) },
        { name: 'Recently onboarded', path: completed_admin_dashboard_school_onboardings_path(current_user) },
        { name: 'Recent activities', path: admin_dashboard_activities_path },
        { name: 'Recent actions', path: admin_reports_interventions_path }
      ]
    end
  end
end
