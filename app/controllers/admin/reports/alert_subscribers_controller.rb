module Admin
  module Reports
    class AlertSubscribersController < AdminController
      def index
        @school_groups = SchoolGroup.organisation_groups.order(name: :asc)
      end
    end
  end
end
