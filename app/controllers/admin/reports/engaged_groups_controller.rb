# frozen_string_literal: true

module Admin
  module Reports
    class EngagedGroupsController < AdminController
      def index
        @engaged_groups =
          SchoolGroup
          .by_name
          .joins("JOIN (#{School.active.group(:school_group_id).select(:school_group_id, 'count(*)').to_sql}) " \
                 'AS active ON school_groups.id = active.school_group_id')
          .joins("JOIN (#{School.engaged(AcademicYear.current.start_date..).group(:school_group_id)
                                .select(:school_group_id, 'count(*)').to_sql}) " \
                 'AS engaged ON school_groups.id = engaged.school_group_id')
          .joins(:default_issues_admin_user)
          .select('school_groups.*',
                  'active.count AS active_count',
                  'engaged.count AS engaged_count',
                  'users.name AS admin_user_name')
      end
    end
  end
end
