# frozen_string_literal: true

module Navigation
  class AdminDashboardComponent < BaseComponent
    def my_schools_section
      [
        { name: 'Onboarding', path: admin_school_onboardings_path },
        { name: 'Awaiting activation', path: admin_activations_path },
        { name: 'Recently onboarded', path: completed_admin_school_onboardings_path },
        { name: 'Recent activities', path: admin_reports_activities_path },
        { name: 'Recent actions', path: admin_reports_interventions_path }
      ]
    end
  end
end
