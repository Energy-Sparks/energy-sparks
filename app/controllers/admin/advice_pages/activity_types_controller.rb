module Admin
  module AdvicePages
    class ActivityTypesController < AdminController
      def show
        @advice_page = AdvicePage.find(params[:advice_page_id])
        @activity_categories_and_types = ActivityCategory.listed_with_activity_types
        @positions = @advice_page.advice_page_activity_types.each_with_object({}) do |advice_page_activity_types, positions|
          positions[advice_page_activity_types.activity_type_id] = advice_page_activity_types.position
        end
      end

      def update
        @advice_page = AdvicePage.find(params[:advice_page_id])
        position_attributes = params.permit(activity_types: %i[position activity_type_id]).fetch(:activity_types) { {} }
        @advice_page.update_activity_type_positions!(position_attributes)
        redirect_to admin_advice_pages_path, notice: 'Activity types updated'
      end
    end
  end
end
