# frozen_string_literal: true

module Admin
  class DashboardsController < AdminController
    layout 'admin_dashboard'

    authorize_resource class: false

    def index
      @ad_users = User.where(role: 'admin').order(:name)
    end

    def show
      @ad_user = User.where(id: params[:id]).first
    end
  end
end
