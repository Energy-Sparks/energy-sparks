module Admin
  module AlertTypes
    class ActivityTypesController < AdminController
      def show
        @alert_type = AlertType.find(params[:alert_type_id])
        @activity_categories_and_types = ActivityCategory.listed_with_activity_types
      end

      def update
        alert_type = AlertType.find(params[:alert_type_id])
        alert_type.update!(params.require(:alert_type).permit(activity_type_ids: []))
        redirect_to admin_alert_type_activity_types_path(alert_type), notice: 'Activity types updated'
      end
    end
  end
end
