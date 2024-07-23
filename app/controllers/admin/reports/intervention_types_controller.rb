module Admin
  module Reports
    class InterventionTypesController < AdminController
      load_and_authorize_resource

      def index
        @activity_types = InterventionType.by_name
      end

      def show
        @activities = @intervention_type.activities.most_recent
        @observations = @intervention_type.observations.order(created_at: :desc)
        @recorded = @intervention_type.observations.count
        @school_count = @intervention_type.unique_school_count
        @group_by_school = @intervention_type.observations.group(:school).count
      end

      def unique_school_count
        activities.select(:school_id).distinct.count
      end


      # private

      # def group_by_school
      #   @activity_type.grouped_school_count.to_a.sort {|a, b| b[1] <=> a[1]}
      # end
    end
  end
end
