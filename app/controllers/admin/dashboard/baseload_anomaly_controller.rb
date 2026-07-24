# frozen_string_literal: true

module Admin
  module Dashboard
    class BaseloadAnomalyController < Admin::Reports::BaseloadAnomalyController
      include AdminDashboard

      before_action :set_user

      helper_method :index_button

      def index
        super
        build_breadcrumbs([
                            { name: @dashboard_user.display_name, href: admin_dashboard_path(@dashboard_user) },
                            { name: 'Baseload anomalies' }
                          ])
      end

      def index_button
        { text: 'View all baseload anomalies',
          path: admin_reports_baseload_anomaly_index_path }
      end
    end
  end
end
