# frozen_string_literal: true

module Admin
  class DashboardsController < AdminController
    include AdminDashboard

    layout 'admin_dashboard'

    def index
      @dashboard_users = User.admin.where(operations: true).order(:name)
    end

    def show
      set_user
      set_breadcrumbs
      if params[:school_group].present?
        redirect_to admin_dashboard_school_group_path(@dashboard_user, id: params[:school_group])
      elsif params[:school].present?
        redirect_to school_meters_path(school_id: params[:school])
      end
    end
  end
end
