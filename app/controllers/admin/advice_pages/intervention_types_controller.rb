module Admin
  module AdvicePages
    class InterventionTypesController < AdminController
      def show
        @advice_page = AdvicePage.find(params[:advice_page_id])
        @intervention_type_groups_and_types = InterventionTypeGroup.listed_with_intervention_types

        @positions = @advice_page.advice_page_intervention_types.inject({}) do |positions, advice_page_intervention_types|
          positions[advice_page_intervention_types.intervention_type_id] = advice_page_intervention_types.position
          positions
        end
      end

      def update
        @advice_page = AdvicePage.find(params[:advice_page_id])
        position_attributes = params.permit(intervention_types: [:position, :intervention_type_id]).fetch(:intervention_types) { {} }
        @advice_page.update_intervention_type_positions!(position_attributes)
        redirect_to admin_advice_pages_path, notice: 'Intervention types updated'
      end
    end
  end
end
