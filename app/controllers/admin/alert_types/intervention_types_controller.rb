module Admin
  module AlertTypes
    class InterventionTypesController < AdminController
      def show
        @alert_type = AlertType.find(params[:alert_type_id])
        @rating = @alert_type.ratings.find(params[:rating_id])

        @intervention_type_groups_and_types = InterventionTypeGroup.listed_with_intervention_types
        @positions = @rating.alert_type_rating_intervention_types.each_with_object({}) do |alert_type_intervention_types, positions|
          positions[alert_type_intervention_types.intervention_type_id] = alert_type_intervention_types.position
        end
      end

      def update
        alert_type = AlertType.find(params[:alert_type_id])
        rating = alert_type.ratings.find(params[:rating_id])

        position_attributes = params.permit(intervention_types: %i[position intervention_type_id]).fetch(:intervention_types) { {} }
        rating.update_intervention_type_positions!(position_attributes)
        redirect_to admin_alert_type_ratings_path(alert_type), notice: 'Actions updated'
      end
    end
  end
end
