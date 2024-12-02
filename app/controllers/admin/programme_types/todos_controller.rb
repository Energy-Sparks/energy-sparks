module Admin
  module ProgrammeTypes
    class TodosController < AdminController
      load_and_authorize_resource :programme_type

      def edit
      end

      def update
        if @programme_type.update(assignable_params)
          redirect_to admin_programme_types_path, notice: 'Programme type todos updated'
        else
          render :edit
        end
      end

      private

      def assignable_params
        params.require(:programme_type).permit(
          activity_type_todos_attributes: todos_attributes,
          intervention_type_todos_attributes: todos_attributes)
      end

      def todos_attributes
        [:id, :task_id, :task, :task_type, :position, :notes, :_destroy]
      end
    end
  end
end
