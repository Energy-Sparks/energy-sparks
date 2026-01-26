# frozen_string_literal: true

module Admin
  class IssuesController < AdminController
    include Pagy::Backend
    load_and_authorize_resource :school, instance_name: 'issueable'
    load_and_authorize_resource :school_group, instance_name: 'issueable'
    load_and_authorize_resource :data_source, instance_name: 'issueable'
    load_and_authorize_resource :school_onboarding, instance_name: 'issueable', find_by: :uuid
    load_and_authorize_resource :issue, through: :issueable, shallow: true, except: [:meter_issues]
    load_and_authorize_resource :school # For school context menu if school available

    def index
      params[:issue_types] ||= Issue.issue_types.keys
      params[:statuses] ||= Issue.statuses.keys

      if @issueable.is_a?(SchoolGroup) && params[:all]
        # School group admin csv download
        # Includes all school group and school issues
        @issues = @issueable.all_issues.active if @issueable.is_a?(SchoolGroup)
      else
        @issues = @issues.active.for_issue_types(params[:issue_types])
        @issues = @issues.for_statuses(params[:statuses])
        @issues = @issues.for_owned_by(params[:user]) if params[:user].present?
        @issues = @issues.search(params[:search]) if params[:search].present?

        if params[:review_date]
          @issues = @issues.where(review_date: nil) if params[:review_date] == 'review_unset'
          @issues = @issues.where('review_date BETWEEN ? AND ?', Time.zone.now, 7.days.from_now) if params[:review_date] == 'review_next_week'
          @issues = @issues.where('review_date <= ?', Time.zone.now) if params[:review_date] == 'review_overdue'
        end
      end

      @issues = @issues.includes(:issueable, :owned_by, :created_by, :updated_by)

      respond_to do |format|
        format.html do
          @pagy, @issues = pagy(@issues.by_priority_order)
        end
        format.csv do
          issues = @issues.with_rich_text_description.includes(meters: [:data_source, :admin_meter_status])

          send_data issues.to_csv,
                    filename: EnergySparks::Filenames.csv('issues')
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
      @issue.resolve!(updated_by: current_user)
      redirect_back_or_index notice: 'was successfully resolved'
    end

    def meter_issues
      @meter = Meter.find(params[:meter_id])
      respond_to(&:js)
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
      [@issue.issueable.try(:model_name).try(:human), @issue.issue_type, notice].compact.join(' ').capitalize
    end

    def issue_params
      params.require(:issue).permit(:issue_type, :title, :description, :fuel_type, :status, :owned_by_id, :review_date, :pinned,
                                    meter_ids: [])
    end
  end
end
