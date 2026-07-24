# frozen_string_literal: true

module Admin
  module Dashboard
    class ActivitiesController < Admin::Reports::ActivitiesController
      include AdminDashboard

      before_action :set_user

      def apply_dashboard_filters(activities)
        build_breadcrumbs([
                            { name: @dashboard_user.display_name, href: admin_dashboard_path(@dashboard_user) },
                            { name: 'Activities' }
                          ])
        activities.for_admin(@dashboard_user)
      end
    end
  end
end
