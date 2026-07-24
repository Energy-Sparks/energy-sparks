# frozen_string_literal: true

module Navigation
  class AdminDashboardComponent < BaseComponent
    def nav_sections
      [
        { name: 'My School Groups', path: admin_dashboard_school_groups_path(current_user),
          match_on_param: { param: 'group_type', value: nil } },
        { name: 'My Project Groups', path: admin_dashboard_school_groups_path(current_user, group_type: 'project') },
        { name: 'My Impact Reports', path: admin_dashboard_impact_reports_path(current_user) },
        { name: 'My Data Sources', path: admin_dashboard_data_sources_path(current_user) },
        { name: 'My Suppliers', path: admin_dashboard_suppliers_path(current_user) },
        { name: 'My Data Feeds', path: admin_dashboard_amr_data_feed_configs_path(current_user) },
        { name: 'My Issues', path: admin_dashboard_issues_path(current_user) },
        { name: 'My Energy Tariffs', path: admin_dashboard_energy_tariffs_path(current_user) }
      ]
    end

    def my_schools_section # rubocop:disable Metrics/AbcSize
      [
        { name: 'Onboarding', classes: 'small', path: admin_dashboard_school_onboardings_path(current_user) },
        { name: 'Awaiting activation', classes: 'small', path: admin_dashboard_activations_path(current_user) },
        { name: 'Recently onboarded', classes: 'small',
          path: completed_admin_dashboard_school_onboardings_path(current_user) },
        { name: 'Engaged schools', classes: 'small', path: admin_dashboard_engaged_groups_path(current_user) },
        { name: 'Recent activities', classes: 'small', path: admin_dashboard_activities_path(current_user) },
        { name: 'Recent actions', classes: 'small', path: admin_dashboard_interventions_path(current_user) },
        { name: 'Limited users', classes: 'small',
          path: admin_dashboard_limited_users_path(current_user) },
        { name: 'Missing alert contacts', classes: 'small',
          path: admin_dashboard_missing_alert_contacts_path(current_user) },
        { name: 'Pupil number updates', classes: 'small',
          path: admin_dashboard_pupil_number_updates_path(dashboard_id: current_user, admin: current_user) }
      ]
    end

    def my_meters_section
      [
        { name: 'New data for inactive meters', classes: 'small',
          path: admin_dashboard_new_data_inactive_meter_report_index_path(dashboard_id: current_user,
                                                                          admin: current_user.id) },
        { name: 'Baseload anomalies', classes: 'small',
          path: admin_dashboard_baseload_anomaly_index_path(dashboard_id: current_user,
                                                            admin: current_user.id) },
        { name: 'Manually read meters', classes: 'small',
          path: admin_dashboard_manual_reads_path(dashboard_id: current_user,
                                                  admin: current_user.id) }
      ]
    end
  end
end
