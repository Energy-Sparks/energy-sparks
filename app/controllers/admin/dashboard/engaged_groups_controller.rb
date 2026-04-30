# frozen_string_literal: true

module Admin
  module Dashboard
    class EngagedGroupsController < Admin::Reports::EngagedGroupsController
      include AdminDashboard

      before_action :set_user

      def index
        super
        build_breadcrumbs([
                            { name: @dashboard_user.display_name, href: admin_dashboard_path(@dashboard_user) },
                            { name: 'Engaged Schools' }
                          ])
      end
    end
  end
end
