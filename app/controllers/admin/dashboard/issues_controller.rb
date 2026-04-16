# frozen_string_literal: true

module Admin
  module Dashboard
    class IssuesController < Admin::IssuesController
      include AdminDashboard

      before_action :set_user

      def index
        super
        build_breadcrumbs([
                            { name: @dashboard_user.display_name, href: admin_dashboard_path(@dashboard_user) },
                            { name: 'Issues' }
                          ])
      end

      private

      def dashboard_issues
        @issues = @issues.where(owned_by: @dashboard_user) if @dashboard_user
      end
    end
  end
end
