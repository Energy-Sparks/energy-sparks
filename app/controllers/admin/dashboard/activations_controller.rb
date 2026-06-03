# frozen_string_literal: true

module Admin
  module Dashboard
    class ActivationsController < Admin::ActivationsController
      include AdminDashboard

      before_action :set_user

      def index
        @school_groups = SchoolGroup.organisation_groups.where(default_issues_admin_user: @dashboard_user)
                                    .by_name.select(&:has_schools_awaiting_activation?)
        build_breadcrumbs([
                            { name: @dashboard_user.display_name, href: admin_dashboard_path(@dashboard_user) },
                            { name: 'Activations' }
                          ])
      end
    end
  end
end
