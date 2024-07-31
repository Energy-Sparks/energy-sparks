module Admin
  module Reports
    class InterventionTypesController < AdminController
      load_and_authorize_resource

      def index
        @activity_types = InterventionType.by_name
      end

      def show
        @observations = @intervention_type.observations.order(created_at: :desc)
        @recorded = @intervention_type.observations.count
        @school_count = @intervention_type.observations.select(:school_id).distinct.count
        @group_by_school = @intervention_type.observations.group(:school).count
      end

      def unique_school_count
        activities.select(:school_id).distinct.count
      end
    end
  end
end
