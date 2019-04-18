module Admin
  module AlertTypes
    class ActivityTypesController < AdminController
      def show
        @alert_type = AlertType.find(params[:alert_type_id])
        @activity_categories_and_types = ActivityCategory.listed_with_activity_types
        @positions = @alert_type.alert_type_activity_types.inject({}) do |positions, alert_type_activity_types|
          positions[alert_type_activity_types.activity_type_id] = alert_type_activity_types.position
          positions
        end
      end

      def update
        alert_type = AlertType.find(params[:alert_type_id])
        position_attributes = params.permit(activity_types: [:position, :activity_type_id]).fetch(:activity_types) { {} }
        alert_type.update_activity_type_positions!(position_attributes)
        redirect_to admin_alert_type_activity_types_path(alert_type), notice: 'Activity types updated'
      end
    end
  end
end
