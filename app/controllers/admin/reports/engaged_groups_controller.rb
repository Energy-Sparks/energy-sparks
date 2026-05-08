# frozen_string_literal: true

module Admin
  module Reports
    class EngagedGroupsController < AdminController
      def index
        @engaged_groups =
          SchoolGroup
          .organisation_groups
          .by_name
          .count_active_schools
          .count_engaged_schools
          .left_joins(:default_issues_admin_user)
          .select('school_groups.*',
                  'COALESCE(active.count, 0) AS active_count',
                  'COALESCE(engaged.count, 0) AS engaged_count',
                  'users.name AS admin_user_name')

        return unless request.post?

        EngagedSchoolsReportJob.perform_later(current_user.email, params[:previous], params[:school_group_id])
        redirect_back_or_to admin_reports_engaged_groups_path,
                            notice: "Report sent to #{current_user.email}"
      end
    end
  end
end
