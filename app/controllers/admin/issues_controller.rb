# frozen_string_literal: true

module Admin
  class IssuesController < AdminController
    include Pagy::Method
    include SchoolGroupBreadcrumbs
    include ActionView::Helpers::UrlHelper

    before_action :enable_bootstrap5

    load_and_authorize_resource :school
    load_and_authorize_resource :school_group
    load_and_authorize_resource :data_source
    load_and_authorize_resource :supplier
    load_and_authorize_resource :school_onboarding, find_by: :uuid
    before_action :set_issueable # used by through: issueable below
    load_and_authorize_resource :issue, through: :issueable, shallow: true, except: [:meter_issues]

    ALL_METER_TYPES = { fuel: Meter.meter_types.keys, system: Meter.meter_systems.keys }
                      .flat_map { |type, subtypes| subtypes.map { |subtype| [type, subtype] } }
    ALLOWED_ALL_METER_TYPES = ALL_METER_TYPES.map(&:second)
    private_constant :ALLOWED_ALL_METER_TYPES

    def index
      params[:issue_types] ||= Issue.issue_types.keys
      params[:statuses] ||= Issue.statuses.keys

      filter_issues
      @issues = @issues.includes(:issueable, :owned_by, :created_by, :updated_by)

      format
    end

    def new
      @issue = Issue.new(issue_type: params[:issue_type], issueable: @issueable, meter_ids: params[:meter_ids])
    end

    def edit
      @custom_mpxns = @issue.meters.pluck(:mpan_mprn).join(' ')
    end

    def create
      @issue.attributes = { created_by: current_user, updated_by: current_user }
      if @issue.save
        process_affected_meters
        redirect_to url_from(params[:redirect_back]), notice: issueable_notice('was successfully created')
      else
        render :new
      end
    end

    def update
      if @issue.update(issue_params.merge(updated_by: current_user))
        process_affected_meters
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
      @meter = Meter.find(params.expect(:meter_id))
      respond_to(&:js)
    end

    private

    def format
      issues = sorted_issues
      respond_to do |format|
        format.html do
          @pagy, @issues = pagy(issues)
          if @issueable.is_a?(SchoolGroup)
            breadcrumbs
            render :index, layout: 'group_settings'
          end
        end
        format.csv do
          issues = issues.with_rich_text_description.includes(:issue_tags, meters: %i[data_source admin_meter_status])
          send_data issues.to_csv, filename: EnergySparks::Filenames.csv('issues')
        end
      end
    end

    def sorted_issues
      column = params[:sort]&.presence_in(Issue.column_names)
      if column
        @issues.order(Issue.arel_table[column].public_send(params[:direction]&.presence_in(%w[asc desc])).nulls_last)
      else
        @issues.by_priority_order
      end
    end

    def set_issueable
      # For school context menu if school available
      @issueable = @school || @school_group || @data_source || @supplier || @school_onboarding
    end

    def redirect_index(notice:)
      redirect_to issueable_index_url, notice: issueable_notice(notice)
    end

    def redirect_back_or_index(notice:)
      redirect_back_or_to(issueable_index_url, notice: issueable_notice(notice))
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
      params.expect(issue: [:issue_type, :title, :description, :fuel_type, :status, :owned_by_id, :review_date, :pinned,
                            { meter_ids: [] }, { issue_tag_ids: [] }])
    end

    def breadcrumbs
      build_breadcrumbs([{ name: t('school_groups.titles.issues') }]) if @issueable.is_a?(SchoolGroup)
    end

    def process_affected_meters
      return if params[:issue][:meter_ids]

      meter_ids = process_all_meter_ids.to_set
      meter_ids += Meter.where(mpan_mprn: params[:custom_mpxns].split(/[,\s;]+/)).pluck(:id) if params[:custom_mpxns]
      @issue.meter_ids = meter_ids if @issue.meter_ids.to_set != meter_ids
    end

    def process_all_meter_ids
      ((params[:all_meter_ids] || []) & ALLOWED_ALL_METER_TYPES).flat_map do |type|
        @issue.issueable.meters.active.public_send(type).pluck(:id)
      end
    end

    def filter_issues
      return if filter_all?

      # Only show issues for archived schools in a school context
      @issues = @issues.active unless @issueable.is_a?(School)
      { issue_types: :for_issue_types,
        statuses: :for_statuses,
        user: :for_owned_by,
        search: :search,
        issue_tag: :for_issue_tag }.each do |param, scope|
          @issues = @issues.public_send(scope, params[param]) if params[param].present?
        end
      filter_review_date
    end

    def filter_all?
      return false unless @issueable.is_a?(SchoolGroup) && params[:all]

      # School group admin csv download
      # Includes all school group and school issues
      @issues = @issueable.all_issues.active
      true
    end

    def filter_review_date
      @issues = case params[:review_date]
                when 'review_unset'
                  @issues.where(review_date: nil)
                when 'review_next_week'
                  @issues.where('review_date BETWEEN ? AND ?', Time.zone.now, 7.days.from_now)
                when 'review_overdue'
                  @issues.where(review_date: ..Time.zone.now)
                else
                  @issues
                end
    end
  end
end
