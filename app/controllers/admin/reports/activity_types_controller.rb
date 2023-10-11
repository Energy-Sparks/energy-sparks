module Admin
  module Reports
    class ActivityTypesController < AdminController
      load_and_authorize_resource

      def index
        @activity_types = ActivityType.by_name
      end

      def show
        @activities = @activity_type.activities.most_recent
        @recorded = @activity_type.activities.count
        @school_count = @activity_type.unique_school_count
        @group_by_school = group_by_school
      end

      private

      def group_by_school
        @activity_type.grouped_school_count.to_a.sort { |a, b| b[1] <=> a[1] }
      end
    end
  end
end
