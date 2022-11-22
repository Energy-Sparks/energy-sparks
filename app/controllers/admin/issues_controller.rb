module Admin
  class IssuesController < AdminController
    include Pagy::Backend
    before_action :header_fix_enabled

    load_and_authorize_resource :school, instance_name: 'issueable'
    load_and_authorize_resource :school_group, instance_name: 'issueable'
    load_and_authorize_resource :issue, through: :issueable, shallow: true

    def index
      @issues = @issueable ? @issueable.issues : Issue.all
      @pagy, @issues = pagy(@issues.by_pinned.by_updated_at)
    end

    def new
      @issue = Issue.new(issue_type: params[:issue_type], issueable: @issueable)
    end

    def create
      @issue.attributes = { created_by: current_user, updated_by: current_user }
      if @issue.save
        redirect_index notice: 'was successfully created'
      else
        render :new
      end
    end

    def update
      if @issue.update(issue_params.merge(updated_by: current_user))
        redirect_index notice: 'was successfully updated'
      else
        render :edit
      end
    end

    def destroy
      @issue.destroy
      redirect_index notice: 'was successfully deleted'
    end

    def resolve
      notice = "#{@issue.issue_type.capitalize} was successfully resolved."
      unless @issue.resolve!(updated_by: current_user)
        notice = "Can only resolve issues (and not notes)."
      end
      redirect_back fallback_location: issueable_index, notice: notice
    end

    private

    def redirect_index(notice:)
      redirect_to issueable_url, notice: issueable_notice(notice)
    end

    def issueable_index
      @issueable ? url_for([:admin, @issueable, :issues]) : url_for([:admin, :issues])
    end

    def issueable_notice(notice: '')
      issueable_notice = "#{@issue.issue_type.capitalize} #{notice}"
      issueable_notice = "#{@issueable.model_name.human} #{issueable_notice}" if @issueable
      return issueable_notice
    end

    def issue_params
      params.require(:issue).permit(:issue_type, :title, :description, :fuel_type, :status, :owned_by_id, :pinned)
    end
  end
end
