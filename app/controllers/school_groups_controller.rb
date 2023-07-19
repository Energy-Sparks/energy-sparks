class SchoolGroupsController < ApplicationController
  include PartnersHelper
  include Promptable

  before_action :find_school_group
  before_action :redirect_unless_feature_enabled, only: [:map, :comparisons, :priority_actions, :current_scores]
  before_action :redirect_unless_authorised, only: [:comparisons, :priority_actions, :current_scores]
  before_action :find_schools_and_partners
  before_action :build_breadcrumbs
  before_action :find_school_group_fuel_types
  before_action :set_show_school_group_message
  before_action :header_fix_enabled, if: -> { can?(:update_settings, @school_group) }

  skip_before_action :authenticate_user!

  def show
    if EnergySparks::FeatureFlags.active?(:enhanced_school_group_dashboard)
      enhanced_dashboard
    else
      current_dashboard
    end
  end

  def map
  end

  def comparisons
    respond_to do |format|
      format.html {}
      format.csv do
        filename = "#{@school_group.name}-#{I18n.t('school_groups.titles.comparisons')}-#{Time.zone.now.strftime('%Y-%m-%d')}".parameterize + ".csv"
        send_data SchoolGroups::ComparisonsCsvGenerator.new(school_group: @school_group, advice_page_keys: params['advice_page_keys'], include_cluster: include_cluster).export,
        filename: filename
      end
    end
  end

  def priority_actions
    respond_to do |format|
      format.html do
        service = SchoolGroups::PriorityActions.new(@school_group)
        @priority_actions = service.priority_actions
        @total_savings = sort_total_savings(service.total_savings)
      end
      format.csv do
        send_data priority_actions_csv, filename: csv_filename_for('priority_actions')
      end
    end
  end

  def current_scores
    respond_to do |format|
      format.html {}
      format.csv do
        send_data SchoolGroups::CurrentScoresCsvGenerator.new(school_group: @school_group, include_cluster: include_cluster).export,
        filename: csv_filename_for('current_scores')
      end
    end
  end

  private

  def csv_filename_for(action)
    title = I18n.t("school_groups.titles.#{action}")
    "#{@school_group.name}-#{title}-#{Time.zone.now.strftime('%Y-%m-%d')}".parameterize + ".csv"
  end

  def priority_actions_csv
    if params[:alert_type_rating_ids]
      SchoolGroups::SchoolsPriorityActionCsvGenerator.new(
        school_group: @school_group,
        alert_type_rating_ids: params[:alert_type_rating_ids].map(&:to_i),
        include_cluster: include_cluster
      ).export
    else
      SchoolGroups::PriorityActionsCsvGenerator.new(school_group: @school_group).export
    end
  end

  def set_show_school_group_message
    @show_school_group_message = show_school_group_message?
  end

  def show_school_group_message?
    return false unless @school_group&.dashboard_message

    show_standard_prompts?(@school_group)
  end

  def sort_total_savings(total_savings)
    total_savings.sort do |a, b|
      b[1].average_one_year_saving_gbp <=> a[1].average_one_year_saving_gbp
    end
  end

  def find_school_group_fuel_types
    @fuel_types = @school_group.fuel_types
  end

  def redirect_unless_feature_enabled
    redirect_to school_group_path(@school_group) and return unless EnergySparks::FeatureFlags.active?(:enhanced_school_group_dashboard)
  end

  def redirect_unless_authorised
    redirect_to map_school_group_path(@school_group) and return if cannot?(:compare, @school_group)
  end

  def find_school_group
    @school_group = SchoolGroup.find(params[:id])
  end

  def build_breadcrumbs
    @breadcrumbs = [
      { name: I18n.t('common.schools'), href: schools_path },
      { name: @school_group.name, href: school_group_path(@school_group) },
      { name: I18n.t("school_groups.titles.#{action_name}") }
    ]
  end

  def find_schools_and_partners
    @schools = @school_group.schools.visible.by_name
    @partners = @school_group.partners
  end

  def current_dashboard
    authorize! :show, @school_group
    render 'current_dashboard'
  end

  def enhanced_dashboard
    if can?(:compare, @school_group)
      respond_to do |format|
        format.html do
          render 'recent_usage'
        end
        format.csv do
          send_data SchoolGroups::RecentUsageCsvGenerator.new(school_group: @school_group, include_cluster: include_cluster).export,
          filename: csv_filename_for('recent_usage')
        end
      end
    else
      redirect_to map_school_group_path(@school_group) and return
    end
  end

  def include_cluster
    can?(:update_settings, @school_group)
  end
end
