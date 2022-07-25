module Admin
  module Reports
    class ActivityTypesController < AdminController
      load_and_authorize_resource

      def index
        @activity_types = ActivityType.order(:name)
      end

      def show
        @activities = Activity.where(activity_type: @activity_type).order(:created_at)
        @recorded = Activity.where(activity_type: @activity_type).count
        @school_count = Activity.select(:school_id).where(activity_type: @activity_type).distinct.count
        @group_by_school = group_by_school.to_a.sort {|a, b| b[1] <=> a[1]}
      end

      private

      def group_by_school
        Activity.where(activity_type: @activity_type).group(:school).count
      end
    end
  end
end
