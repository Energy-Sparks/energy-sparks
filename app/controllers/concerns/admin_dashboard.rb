# frozen_string_literal: true

module AdminDashboard
  extend ActiveSupport::Concern

  included do
    layout 'admin_dashboard'
    before_action :set_metadata, :set_breadcrumbs
  end

  private

  def set_metadata
    @admin = User.find(params[:dashboard_id])
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
