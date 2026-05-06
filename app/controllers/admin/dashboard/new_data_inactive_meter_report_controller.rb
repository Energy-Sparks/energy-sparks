# frozen_string_literal: true

module Admin
  module Dashboard
    class NewDataInactiveMeterReportController < Admin::Reports::NewDataInactiveMeterReportController
      include AdminDashboard

      before_action :set_user

      helper_method :index_button

      def index
        super
        build_breadcrumbs([
                            { name: @dashboard_user.display_name, href: admin_dashboard_path(@dashboard_user) },
                            { name: 'New data for inactive meters' }
                          ])
      end

      def index_button
        { text: 'View all new inactive meter data',
          path: admin_reports_new_data_inactive_meter_report_index_path }
      end
    end
  end
end
