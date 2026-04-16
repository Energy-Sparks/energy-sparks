# frozen_string_literal: true

module Navigation
  class AdminDashboardComponent < BaseComponent
    def my_schools_section
      [
        { name: 'Onboarding', path: admin_dashboard_school_onboardings_path(current_user) },
        { name: 'Awaiting activation', path: admin_dashboard_activations_path(current_user) },
        { name: 'Recently onboarded', path: completed_admin_dashboard_school_onboardings_path(current_user) },
        { name: 'Recent activities', path: admin_reports_activities_path },
        { name: 'Recent actions', path: admin_reports_interventions_path }
      ]
    end
  end
end
