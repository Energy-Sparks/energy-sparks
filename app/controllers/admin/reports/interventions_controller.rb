module Admin
  module Reports
    class InterventionsController < AdminController
      def index
        @observations = Observation.intervention.recorded_in_last_year.order(created_at: :desc)
      end
    end
  end
end
