# frozen_string_literal: true

module AdminDashboard
  extend ActiveSupport::Concern

  included do
    layout 'admin_dashboard'
    before_action :set_admin_user, :set_metadata
  end

  private

  def set_metadata
    @title = title
  end

  def set_admin_user
    @admin = User.find(params[:dashboard_id])
  end
end
