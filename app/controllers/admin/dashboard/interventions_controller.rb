# frozen_string_literal: true

module Admin
  module Dashboard
    class InterventionsController < Admin::Reports::InterventionsController
      include AdminDashboard

      before_action :set_user

      def apply_dashboard_filters(observations)
        build_breadcrumbs([
                            { name: @dashboard_user.display_name, href: admin_dashboard_path(@dashboard_user) },
                            { name: 'Interventions' }
                          ])
        observations.for_admin(@dashboard_user)
      end
    end
  end
end
