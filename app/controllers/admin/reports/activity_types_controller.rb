module Admin
  module Reports
    class ActivityTypesController < AdminController
      load_and_authorize_resource

      def index
        @activity_types = ActivityType.order(:name)
      end

      def show
        @recorded = Activity.where(activity_type: @activity_type).count
        @school_count = Activity.select(:school_id).where(activity_type: @activity_type).distinct.count
      end
    end
  end
end
