module Admin
  module Reports
    class ActivitiesController < AdminController
      def index
        @activities = Activity.includes(:observations, :school, :activity_type, observations: :created_by, school: :school_group, rich_text_description: { embeds_attachments: :blob }).recorded_in_last_year.order(created_at: :desc)
      end
    end
  end
end
