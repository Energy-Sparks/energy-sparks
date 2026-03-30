# frozen_string_literal: true

module Admin
  module Dashboard
    class SchoolGroupsController < Admin::SchoolGroupsController
      include AdminDashboard

      before_action :set_user

      def index
        super
        @school_groups = @school_groups.where(default_issues_admin_user: @dashboard_user) if @dashboard_user
        build_breadcrumbs([
                            { name: @dashboard_user.display_name, href: admin_dashboard_path(@dashboard_user) },
                            { name: 'School Groups' }
                          ])
      end

      def show
        @title = @school_group.name
        build_breadcrumbs([
                            { name: @dashboard_user.display_name, href: admin_dashboard_path(@dashboard_user) },
                            { name: 'School Groups',
                              href: admin_dashboard_school_groups_path(dashboard_id: @dashboard_user.id) },
                            { name: @school_group.name }
                          ])
      end
    end
  end
end
