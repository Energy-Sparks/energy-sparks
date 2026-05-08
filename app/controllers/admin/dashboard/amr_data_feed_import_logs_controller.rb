# frozen_string_literal: true

module Admin
  module Dashboard
    class AmrDataFeedImportLogsController < Admin::Reports::AmrDataFeedImportLogsController
      include AdminDashboard

      before_action :set_user

      def index
        super
        build_breadcrumbs([
                            { name: @dashboard_user.display_name, href: admin_dashboard_path(@dashboard_user) },
                            { name: 'Data feed import logs' }
                          ])
      end
    end
  end
end
