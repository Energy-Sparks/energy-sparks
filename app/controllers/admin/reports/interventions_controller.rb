module Admin
  module Reports
    class InterventionsController < AdminController
      def index
        @observations = Observation.includes(:school, :intervention_type, :created_by, school: :school_group, rich_text_description: { embeds_attachments: :blob }).intervention.recorded_in_last_year.order(created_at: :desc)
      end
    end
  end
end
