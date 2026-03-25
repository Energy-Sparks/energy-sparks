# frozen_string_literal: true

module Admin
  class DashboardsController < AdminController
    layout 'admin_dashboard'
    before_action :set_metadata, :set_breadcrumbs

    def index
      @admins = User.where(role: 'admin').order(:name)
    end

    def show; end

    def title
      @admin&.display_name
    end

    private

    def set_metadata
      @admin = User.where(id: params[:id]).first
      @title = title
    end

    def set_breadcrumbs
      @breadcrumbs = [
        { name: 'Admin', href: admin_path },
        { name: 'Dashboards', href: admin_dashboards_path },
        { name: title }
      ]
    end
  end
end
