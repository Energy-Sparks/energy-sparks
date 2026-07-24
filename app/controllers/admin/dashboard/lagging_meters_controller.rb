# frozen_string_literal: true

module Admin
  module Dashboard
    class LaggingMetersController < Admin::Reports::LaggingMetersController
      include AdminDashboard

      before_action :set_user

      helper_method :index_button

      def index
        super
        build_breadcrumbs([
                            { name: @dashboard_user.display_name, href: admin_dashboard_path(@dashboard_user) },
                            { name: 'Meters with stale data' }
                          ])
      end

      def index_button
        { text: 'View all stale meters',
          path: admin_reports_lagging_meters_path }
      end
    end
  end
end
