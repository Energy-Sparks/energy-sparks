# frozen_string_literal: true

module Admin
  module Dashboard
    class BlankReadingsController < Admin::Reports::BlankReadingsController
      include AdminDashboard

      before_action :set_user

      helper_method :index_button

      def index
        super
        build_breadcrumbs([
                            { name: @dashboard_user.display_name, href: admin_dashboard_path(@dashboard_user) },
                            { name: 'Meters with recent blank readings' }
                          ])
      end

      def index_button
        { text: 'View all blank readings',
          path: admin_reports_blank_readings_path }
      end
    end
  end
end
