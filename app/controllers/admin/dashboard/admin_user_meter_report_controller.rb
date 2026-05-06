# frozen_string_literal: true

module Admin
  module Dashboard
    class AdminUserMeterReportController < Admin::Reports::AdminUserMeterReportController
      include AdminDashboard

      before_action :set_user

      helper_method :index_button

      def index
        super
        build_breadcrumbs([
                            { name: @dashboard_user.display_name, href: admin_dashboard_path(@dashboard_user) },
                            { name: "Meters for #{@dashboard_user.display_name}" }
                          ])
      end

      def index_button
        { text: 'View all admin meter reports',
          path: admin_reports_admin_user_meter_report_index_path }
      end
    end
  end
end
