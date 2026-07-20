# frozen_string_literal: true

module Admin
  module Dashboard
    class LimitedUsersController < Admin::Reports::LimitedUsersController
      include AdminDashboard

      before_action :set_user

      def index
        super
        @schools = @schools.joins(:school_group)
                           .where(school_group: { default_issues_admin_user: @dashboard_user })

        build_breadcrumbs([
                            { name: @dashboard_user.display_name, href: admin_dashboard_path(@dashboard_user) },
                            { name: 'Limited users' }
                          ])
      end
    end
  end
end
