# frozen_string_literal: true

module Admin
  module Dashboard
    class EstimatedReadsController < Admin::Reports::EstimatedReadsController
      include AdminDashboard

      before_action :set_user

      helper_method :index_button

      def index
        super
        build_breadcrumbs([
                            { name: @dashboard_user.display_name, href: admin_dashboard_path(@dashboard_user) },
                            { name: 'Estimated data' }
                          ])
      end

      def index_button
        { text: 'View all estimated reads',
          path: admin_reports_estimated_reads_path }
      end
    end
  end
end
