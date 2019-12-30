module Admin
  module Reports
    class AlertSubscribersController < AdminController
      def index
        @school_groups = SchoolGroup.order(name: :asc)
      end
    end
  end
end
