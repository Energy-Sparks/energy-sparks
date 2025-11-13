# frozen_string_literal: true

module Admin
  module Reports
    class EngagedGroupsController < AdminController
      def index
        @engaged_groups =
          SchoolGroup
          .organisation_groups
          .by_name
          .joins("LEFT JOIN (
                    #{SchoolGrouping.joins(:school)
                      .merge(School.active)
                      .group(:school_group_id)
                      .select(:school_group_id, 'COUNT(*)').to_sql}
                  ) AS active ON school_groups.id = active.school_group_id")
          .joins("LEFT JOIN (
                    #{SchoolGrouping.joins(:school)
                      .merge(School.engaged(AcademicYear.current.start_date..))
                      .group(:school_group_id)
                      .select(:school_group_id, 'COUNT(*)').to_sql}
                  ) AS engaged ON school_groups.id = engaged.school_group_id")
          .left_joins(:default_issues_admin_user)
          .select('school_groups.*',
                  'COALESCE(active.count, 0) AS active_count',
                  'COALESCE(engaged.count, 0) AS engaged_count',
                  'users.name AS admin_user_name')
      end
    end
  end
end
