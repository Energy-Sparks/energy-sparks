module Admin
  module Reports
    class ActivitiesController < AdminController
      def index
        @activities = Activity.includes(:observations, :school, :activity_type, observations: :created_by).recorded_in_last_year.order(created_at: :desc)
      end
    end
  end
end
