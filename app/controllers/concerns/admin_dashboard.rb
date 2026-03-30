# frozen_string_literal: true

module AdminDashboard
  extend ActiveSupport::Concern

  included do
    layout 'admin_dashboard'
  end

  private

  def set_breadcrumbs
    if @dashboard_user
      build_breadcrumbs([
                          { name: @dashboard_user.display_name, href: admin_dashboard_path(@dashboard_user) }
                        ])
    else
      build_breadcrumbs
    end
  end

  def set_user
    @dashboard_user = User.find(params[:dashboard_id] || params[:id])
  end

  def build_breadcrumbs(extra = nil)
    @breadcrumbs = [
      { name: 'Admin', href: admin_path },
      { name: 'Dashboards', href: admin_dashboards_path },
      *extra
    ]
  end
end
