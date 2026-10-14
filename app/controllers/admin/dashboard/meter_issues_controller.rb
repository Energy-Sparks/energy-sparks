# frozen_string_literal: true

module Admin
  module Dashboard
    class MeterIssuesController < Admin::IssuesController
      include AdminDashboard

      before_action :set_user

      def index
        super
        build_breadcrumbs([{ name: @dashboard_user.display_name, href: admin_dashboard_path(@dashboard_user) },
                           { name: 'Meter Issues' }])
      end

      private

      def filter_issues
        @issues = Issue.admin_meter_issues(@dashboard_user)
        super
      end
    end
  end
end
