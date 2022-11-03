module Admin
  module Schools
    class NotesController < AdminController
      include Pagy::Backend

      load_and_authorize_resource :school
      load_and_authorize_resource through: :school

      def index
        @pagy, @notes = pagy(@notes.by_updated_at)
      end

      def new
        @note = @school.notes.new(note_type: params[:note_type])
      end

      def create
        @note.assign_attributes(created_by: current_user, updated_by: current_user)
        if @note.save!
          redirect_to admin_school_notes_path(@school), notice: "#{@note.note_type.capitalize} was successfully created."
        else
          render :new
        end
      end

      def update
        if @note.update(note_params.merge(updated_by: current_user))
          redirect_to admin_school_notes_path(@school), notice: "#{@note.note_type.capitalize} was successfully updated."
        else
          render :edit
        end
      end

      def destroy
        @note.destroy
        redirect_to admin_school_notes_path(@school), notice: "#{@note.note_type.capitalize} was successfully deleted."
      end

      def resolve
        notice = "#{@note.note_type.capitalize} was successfully resolved."
        unless @note.resolve!
          notice = "Can only resolve issues (and not notes)."
        end
        redirect_to admin_school_notes_path(@school), notice: notice
      end

      private

      def note_params
        params.require(:note).permit(:note_type, :title, :description, :fuel_type, :status)
      end
    end
  end
end
