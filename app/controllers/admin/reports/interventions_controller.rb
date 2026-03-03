module Admin
  module Reports
    class InterventionsController < AdminController
      def index
        @observations = Observation.includes(:school, :intervention_type, :created_by).intervention.recorded_in_last_year.order(created_at: :desc)
      end
    end
  end
end
