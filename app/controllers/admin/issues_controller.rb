# frozen_string_literal: true

module Admin
  class IssuesController < AdminController
    include Pagy::Backend
    load_and_authorize_resource :school
    load_and_authorize_resource :school_group
    load_and_authorize_resource :data_source
    load_and_authorize_resource :school_onboarding, find_by: :uuid
    before_action :issueable

    load_and_authorize_resource :issue, through: :issueable, shallow: true, except: [:meter_issues]

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
        redirect_to url_from(params[:redirect_back]), notice: issueable_notice('was successfully created')
      else
        render :new
      end
    end

    def update
      if @issue.update(issue_params.merge(updated_by: current_user))
        redirect_to url_from(params[:redirect_back]), notice: issueable_notice('was successfully updated')
      else
        render :edit
      end
    end

    def bulk_update
      updated_count = Issues::BulkUpdate.new(
        issueable: @issueable,
        user_from: params[:user_from],
        user_to: params[:user_to],
        updated_by: current_user.id
      ).perform

      redirect_to url_from(params[:redirect_back]), notice: "#{helpers.pluralize(updated_count, 'issue')} updated"
    rescue Issues::BulkError => e
      flash.now[:alert] = helpers.safe_join(e.messages, helpers.tag.br)
      render :bulk_edit
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

    def issueable
      # For school context menu if school available
      @issueable ||= @school || @school_group || @data_source || @school_onboarding
    end

    def redirect_index(notice:)
      redirect_to issueable_index_url, notice: issueable_notice(notice)
    end

    def redirect_back_or_index(notice:)
      redirect_back fallback_location: issueable_index_url, notice: issueable_notice(notice)
    end

    def issueable_index_url
      polymorphic_url([:admin, @issue&.issueable || @issueable, Issue].compact)
    end

    def issueable_notice(notice)
      if @issue
        [@issue&.issueable&.model_name&.human, @issue.issue_type, notice].compact.join(' ').capitalize
      else
        notice
      end
    end

    def issue_params
      params.require(:issue).permit(:issue_type, :title, :description, :fuel_type, :status, :owned_by_id, :review_date, :pinned,
                                    meter_ids: [])
    end
  end
end
