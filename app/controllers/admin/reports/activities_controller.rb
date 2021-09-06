module Admin
  module Reports
    class ActivitiesController < AdminController
      def index
        @activities = Activity.all.order(created_at: :desc).limit(50)
      end
    end
  end
end
