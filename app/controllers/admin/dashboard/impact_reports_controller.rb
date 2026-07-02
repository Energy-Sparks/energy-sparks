# frozen_string_literal: true

module Admin
  module Dashboard
    class ImpactReportsController < Admin::ImpactReportsController
      include AdminDashboard

      before_action :set_user

      def index
        super
        @school_groups = @school_groups.where(default_issues_admin_user: @dashboard_user)
        build_breadcrumbs([
                            { name: @dashboard_user.display_name, href: admin_dashboard_path(@dashboard_user) },
                            { name: 'Impact Reports' }
                          ])
      end
    end
  end
end
