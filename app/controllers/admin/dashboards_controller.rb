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
      if params[:school_group_id].present?
        redirect_to admin_dashboard_school_group_path(@dashboard_user, id: params[:school_group_id])
      elsif params[:school_id].present?
        redirect_to school_meters_path(school_id: params[:school_id])
      end
    end
  end
end
