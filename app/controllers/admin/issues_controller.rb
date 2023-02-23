module Admin
  class IssuesController < AdminController
    include Pagy::Backend
    before_action :header_fix_enabled

    load_and_authorize_resource :school, instance_name: 'issueable'
    load_and_authorize_resource :school_group, instance_name: 'issueable'
    load_and_authorize_resource :data_source, instance_name: 'issueable'
    load_and_authorize_resource :issue, through: :issueable, shallow: true
    load_and_authorize_resource :school # For school context menu if school available

    def index
      params[:issue_types] ||= Issue.issue_types.keys
      params[:statuses] ||= Issue.statuses.keys

      @issues = @issues.for_issue_types(params[:issue_types])
      @issues = @issues.for_statuses(params[:statuses])
      @issues = @issues.for_owned_by(params[:user]) if params[:user].present?

      respond_to do |format|
        format.html do
          @pagy, @issues = pagy(@issues.by_priority_order)
        end
        format.csv do
          @issues = @issueable.all_issues if @issueable && @issueable.is_a?(SchoolGroup)
          send_data @issues.by_updated_at.to_csv,
          filename: "#{t('common.application')}-issues-#{Time.zone.now.iso8601}".parameterize + '.csv'
        end
      end
    end

    def new
      @issue = Issue.new(issue_type: params[:issue_type], issueable: @issueable, meter_ids: params[:meter_ids])
    end

    def create
      @issue.attributes = { created_by: current_user, updated_by: current_user }
      if @issue.save
        redirect_to params[:redirect_back], notice: issueable_notice('was successfully created')
      else
        render :new
      end
    end

    def update
      if @issue.update(issue_params.merge(updated_by: current_user))
        redirect_to params[:redirect_back], notice: issueable_notice('was successfully updated')
      else
        render :edit
      end
    end

    def destroy
      @issue.destroy
      redirect_back_or_index notice: 'was successfully deleted'
    end

    def resolve
      notice = "was successfully resolved"
      unless @issue.resolve!(updated_by: current_user)
        notice = "Can only resolve issues (and not notes)."
      end
      redirect_back_or_index notice: notice
    end

    private

    def redirect_index(notice:)
      redirect_to issueable_index_url, notice: issueable_notice(notice)
    end

    def redirect_back_or_index(notice:)
      redirect_back fallback_location: issueable_index_url, notice: issueable_notice(notice)
    end

    def issueable_index_url
      @issue.issueable ? polymorphic_url([:admin, @issue.issueable, Issue]) : polymorphic_url([:admin, Issue])
    end

    def issueable_notice(notice)
      [@issue.issueable.try(:model_name).try(:human), @issue.issue_type, notice].compact.join(" ").capitalize
    end

    def issue_params
      params.require(:issue).permit(:issue_type, :title, :description, :fuel_type, :status, :owned_by_id, :pinned, meter_ids: [])
    end
  end
end
