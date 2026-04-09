# frozen_string_literal: true

module Admin
  module Dashboard
    class AmrDataFeedConfigsController < Admin::AmrDataFeedConfigsController
      include AdminDashboard

      before_action :set_user

      def index
        super
        @configurations = @configurations.where(owned_by: @dashboard_user)
        build_breadcrumbs([
                            { name: @dashboard_user.display_name, href: admin_dashboard_path(@dashboard_user) },
                            { name: 'Data Feeds' }
                          ])
      end
    end
  end
end
