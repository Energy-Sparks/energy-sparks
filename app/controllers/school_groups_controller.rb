# frozen_string_literal: true

class SchoolGroupsController < ApplicationController
  include SchoolGroupAccessControl
  include PartnersHelper
  include Promptable
  include Scoring
  include SchoolGroupBreadcrumbs

  load_resource

  before_action :find_schools_and_partners
  before_action :redirect_unless_authorised, except: [:map]
  before_action :build_breadcrumbs
  before_action :find_school_group_fuel_types
  before_action :set_show_school_group_message

  skip_before_action :authenticate_user!

  def show
    if Flipper.enabled?(:group_dashboards_2025, current_user)
      render :new_show, layout: 'dashboards'
    else
      respond_to do |format|
        format.html {}
        format.csv do
          send_data SchoolGroups::RecentUsageCsvGenerator.new(school_group: @school_group,
                                                              schools: @schools,
                                                              include_cluster: include_cluster).export,
                    filename: csv_filename_for('recent_usage')
        end
      end
    end
  end

  def map; end

  def comparisons
    respond_to do |format|
      format.html do
        @categorised_schools = SchoolGroups::CategoriseSchools.new(schools: @schools).categorise_schools
      end
      format.csv do
        head :bad_request and return unless params['advice_page_keys']

        send_data SchoolGroups::ComparisonsCsvGenerator.new(schools: @schools,
                                                            advice_page_keys: params['advice_page_keys'],
                                                            include_cluster:).export,
                  filename: csv_filename_for('comparisons')
      end
    end
  end

  def priority_actions
    if Flipper.enabled?(:group_dashboards_2025, current_user)
      redirect_to priorities_school_group_advice_path(@school_group) and return
    end
    respond_to do |format|
      format.html do
        service = SchoolGroups::PriorityActions.new(@schools)
        @priority_actions = service.priority_actions
        @total_savings = sort_total_savings(service.total_savings)
      end
      format.csv do
        send_data priority_actions_csv, filename: csv_filename_for('priority_actions')
      end
    end
  end

  def current_scores
    if Flipper.enabled?(:group_dashboards_2025, current_user)
      redirect_to scores_school_group_advice_path(@school_group) and return
    end
    setup_scores_and_years(@school_group)
    respond_to do |format|
      format.html {}
      format.csv do
        send_data SchoolGroups::CurrentScoresCsvGenerator.new(school_group: @school_group,
                                                              scored_schools: @scored_schools,
                                                              include_cluster:).export,
                  filename: csv_filename_for(params[:academic_year].present? ? 'previous_scores' : 'current_scores')
      end
    end
  end

  private

  def csv_filename_for(action)
    title = I18n.t("school_groups.titles.#{action}")
    name = "#{@school_group.name}-#{title}-#{Time.zone.now.strftime('%Y-%m-%d')}".parameterize
    "#{name}.csv"
  end

  def priority_actions_csv
    if params[:alert_type_rating_ids]
      SchoolGroups::SchoolsPriorityActionCsvGenerator.new(
        schools: @schools,
        alert_type_rating_ids: params[:alert_type_rating_ids].map(&:to_i),
        include_cluster:
      ).export
    else
      SchoolGroups::PriorityActionsCsvGenerator.new(schools: @schools).export
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

  def find_school_group
    @school_group = SchoolGroup.find(params[:id])
  end

  def build_breadcrumbs
    set_breadcrumbs(name: I18n.t("school_groups.titles.#{action_name}"))
  end

  def find_schools_and_partners
    @schools = if action_name == :map
                 # Display all active schools on the map view
                 @school_group.schools.active.by_name
               else
                 # Rely on CanCan to filter the list of schools to those that can be shown to the current user
                 @school_group.schools.active.accessible_by(current_ability, :show).by_name
               end
    @partners = @school_group.partners
  end

  def include_cluster
    can?(:update_settings, @school_group)
  end
end
