module Admin
  module Reports
    class InterventionsController < AdminController
      def index
        @observations = Observation.intervention.order(created_at: :desc).limit(50)
      end
    end
  end
end
