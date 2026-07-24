# frozen_string_literal: true

module Admin
  module Dashboard
    class DataSourcesController < Admin::DataSourcesController
      include AdminDashboard

      before_action :set_user

      def index
        super
        @data_sources = @data_sources.where(owned_by: @dashboard_user) if @dashboard_user
        build_breadcrumbs([
                            { name: @dashboard_user.display_name, href: admin_dashboard_path(@dashboard_user) },
                            { name: 'Data Sources' }
                          ])
      end
    end
  end
end
