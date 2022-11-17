module Admin
  module SchoolGroups
    class IssuesController < AdminController
      load_and_authorize_resource :school_group
      load_and_authorize_resource :issue, through: :school_group

      def index
        @issues = @issues.issue.status_open.by_updated_at
        respond_to do |format|
          format.csv do
            send_data @issues.to_csv,
            filename: "#{t('common.application')}-issues-#{@school_group.slug}-#{Time.zone.now.iso8601}".parameterize + '.csv'
          end
        end
      end
    end
  end
end
