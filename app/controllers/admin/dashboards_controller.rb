# frozen_string_literal: true

module Admin
  class DashboardsController < AdminController
    include AdminDashboard

    layout 'admin_dashboard'
    before_action :set_breadcrumbs

    def index
      @admins = User.admin.order(:name)
    end

    def show
      set_metadata
    end

    def title
      @admin&.display_name
    end
  end
end
