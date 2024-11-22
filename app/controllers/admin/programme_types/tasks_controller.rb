module Admin
  module ProgrammeTypes
    class TasksController < AdminController
      load_and_authorize_resource :programme_type

      def edit
      end

      def update
        if @programme_type.update(tasklist_source_params)
          redirect_to admin_programme_types_path, notice: 'Programme type updated'
        else
          render :edit
        end
      end

      private

      def tasklist_source_params
        params.require(:programme_type).permit(
          activity_type_tasks_attributes: tasks_attributes,
          intervention_type_tasks_attributes: tasks_attributes)
      end

      def tasks_attributes
        [:id, :task_source_id, :task_source, :task_source_type, :position, :notes, :_destroy]
      end
    end
  end
end
