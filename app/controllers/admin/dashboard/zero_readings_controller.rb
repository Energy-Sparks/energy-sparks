# frozen_string_literal: true

module Admin
  module Dashboard
    class ZeroReadingsController < Admin::Reports::ZeroReadingsController
      include AdminDashboard

      before_action :set_user

      helper_method :index_button

      def index
        super
        build_breadcrumbs([
                            { name: @dashboard_user.display_name, href: admin_dashboard_path(@dashboard_user) },
                            { name: 'Meters with recent zero readings' }
                          ])
      end

      def index_button
        { text: 'View all zero readings',
          path: admin_reports_zero_readings_path }
      end
    end
  end
end
