module Admin
  module ProgrammeTypes
    class ActivityTypesController < AdminController
      def show
        @programme_type = ProgrammeType.find(params[:programme_type_id])

        @activity_categories_and_types = ActivityCategory.listed_with_activity_types

        @positions = @programme_type.programme_type_activity_types.each_with_object({}) do |programme_type_activity_types, positions|
          positions[programme_type_activity_types.activity_type_id] = programme_type_activity_types.position
        end
      end

      def update
        @programme_type = ProgrammeType.find(params[:programme_type_id])

        position_attributes = params.permit(activity_types: %i[position activity_type_id]).fetch(:activity_types) { {} }
        @programme_type.update_activity_type_positions!(position_attributes)
        redirect_to admin_programme_types_path, notice: 'Activity types updated for Programme Type'
      end
    end
  end
end
