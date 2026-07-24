# frozen_string_literal: true

module Admin
  module Dashboard
    class SuppliersController < Admin::SuppliersController
      include AdminDashboard

      before_action :set_user

      def index
        super
        @suppliers = @suppliers.where(owned_by: @dashboard_user) if @dashboard_user
        build_breadcrumbs([
                            { name: @dashboard_user.display_name, href: admin_dashboard_path(@dashboard_user) },
                            { name: 'Suppliers' }
                          ])
      end
    end
  end
end
