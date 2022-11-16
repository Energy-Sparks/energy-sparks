module Admin
  module Schools
    class IssuesController < AdminController
      include Pagy::Backend
      before_action :header_fix_enabled

      load_and_authorize_resource :school
      load_and_authorize_resource :issue, through: :school

      def index
        @pagy, @issues = pagy(@issues.by_updated_at)
      end

      def new
        @issue = @school.issues.new(issue_type: params[:issue_type])
      end

      def create
        @issue.attributes = { created_by: current_user, updated_by: current_user }
        if @issue.save
          redirect_to admin_school_issues_path(@school), notice: "#{@issue.issue_type.capitalize} was successfully created."
        else
          render :new
        end
      end

      def update
        if @issue.update(issue_params.merge(updated_by: current_user))
          redirect_to admin_school_issues_path(@school), notice: "#{@issue.issue_type.capitalize} was successfully updated."
        else
          render :edit
        end
      end

      def destroy
        @issue.destroy
        redirect_to admin_school_issues_path(@school), notice: "#{@issue.issue_type.capitalize} was successfully deleted."
      end

      def resolve
        notice = "#{@issue.issue_type.capitalize} was successfully resolved."
        unless @issue.resolve!(updated_by: current_user)
          notice = "Can only resolve issues (and not issues)."
        end
        redirect_back fallback_location: admin_school_issues_path(@school), notice: notice
      end

      private

      def issue_params
        params.require(:issue).permit(:issue_type, :title, :description, :fuel_type, :status, :owned_by_id)
      end
    end
  end
end
