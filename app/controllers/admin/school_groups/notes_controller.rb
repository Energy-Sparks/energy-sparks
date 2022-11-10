module Admin
  module SchoolGroups
    class NotesController < AdminController
      load_and_authorize_resource :school_group
      load_and_authorize_resource through: :school_group

      def index
        @notes = @notes.issue.status_open.by_updated_at
        respond_to do |format|
          format.csv do
            send_data @notes.to_csv,
            filename: "#{t('common.application')}-issues-#{@school_group.slug}-#{Time.zone.now.iso8601}".parameterize + '.csv'
          end
        end
      end
    end
  end
end
