module Admin
  module Reports
    class EngagedSchoolsController < AdminController
      def index
        @engaged_schools = School.engaged.joins(:school_group).order('school_groups.name asc, name asc')
      end
    end
  end
end
