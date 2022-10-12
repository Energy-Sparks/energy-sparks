module Admin
  module Reports
    class ActivitiesController < AdminController
      def index
        @activities = Activity.recorded_in_last_year.order(created_at: :desc)
      end
    end
  end
end
