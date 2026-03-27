# frozen_string_literal: true

module Admin
  class DashboardsController < AdminController
    include AdminDashboard

    layout 'admin_dashboard'

    def index
      @dashboard_users = User.admin.order(:name)
    end

    def show
      set_user
      set_breadcrumbs
    end
  end
end
