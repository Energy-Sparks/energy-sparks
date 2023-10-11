module Admin
  module AlertTypes
    class ActivityTypesController < AdminController
      def show
        @alert_type = AlertType.find(params[:alert_type_id])
        @rating = @alert_type.ratings.find(params[:rating_id])
        @activity_categories_and_types = ActivityCategory.listed_with_activity_types
        @positions = @rating.alert_type_rating_activity_types.each_with_object({}) do |alert_type_activity_types, positions|
          positions[alert_type_activity_types.activity_type_id] = alert_type_activity_types.position
        end
      end

      def update
        alert_type = AlertType.find(params[:alert_type_id])
        rating = alert_type.ratings.find(params[:rating_id])
        position_attributes = params.permit(activity_types: %i[position activity_type_id]).fetch(:activity_types) { {} }
        rating.update_activity_type_positions!(position_attributes)
        redirect_to admin_alert_type_ratings_path(alert_type), notice: 'Activity types updated'
      end
    end
  end
end
