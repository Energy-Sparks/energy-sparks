# frozen_string_literal: true

module Admin
  class DashboardsController < AdminController
    before_action :set_user

    layout 'admin_dashboard'

    def index
      @admins = User.where(role: 'admin').order(:name)
    end

    def show; end

    def set_breadcrumbs
      @breadcrumbs = [
        { name: 'Admin', href: admin_path },
        { name: 'Dashboards', href: admin_dashboards_path },
        { name: 'ye' }
      ]
    end

    private

    def set_user
      @admin = User.where(id: params[:id]).first
    end
  end
end
