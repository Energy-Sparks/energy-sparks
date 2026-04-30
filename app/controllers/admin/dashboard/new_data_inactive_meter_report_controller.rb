# frozen_string_literal: true

module Admin
  module Dashboard
    class NewDataInactiveMeterReportController < Admin::Reports::NewDataInactiveMeterReportController
      include AdminDashboard

      before_action :set_user

      def index
        super
        build_breadcrumbs([
                            { name: @dashboard_user.display_name, href: admin_dashboard_path(@dashboard_user) },
                            { name: 'New data for inactive meters' }
                          ])
      end
    end
  end
end
