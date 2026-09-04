# frozen_string_literal: true

module Admin
  module Dashboard
    class LimitedDataController < Admin::Reports::LimitedDataController
      include AdminDashboard

      before_action :set_user

      helper_method :index_button

      def index
        super
        build_breadcrumbs([
                            { name: @dashboard_user.display_name, href: admin_dashboard_path(@dashboard_user) },
                            { name: 'Limited data' }
                          ])
      end

      def index_button
        { text: 'View all limited data meters',
          path: admin_reports_limited_data_path }
      end
    end
  end
end
