module Admin
  module Reports
    class EngagedSchoolsController < AdminController
      def index
        @engaged_schools = School.engaged.by_name
      end
    end
  end
end
