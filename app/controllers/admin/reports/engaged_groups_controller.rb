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
      end
    end
  end
end
