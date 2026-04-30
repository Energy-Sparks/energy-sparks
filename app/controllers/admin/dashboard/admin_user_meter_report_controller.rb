# frozen_string_literal: true

module Admin
  module Dashboard
    class AdminUserMeterReportController < Admin::Reports::AdminUserMeterReportController
      include AdminDashboard

      before_action :set_user

      def index
        super
        build_breadcrumbs([
                            { name: @dashboard_user.display_name, href: admin_dashboard_path(@dashboard_user) },
                            { name: "Meters for #{@dashboard_user.display_name}" }
                          ])
      end
    end
  end
end
