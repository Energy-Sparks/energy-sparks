# frozen_string_literal: true

class SchoolGroupsController < ApplicationController
  include SchoolGroupAccessControl
  include PartnersHelper
  include Promptable
  include Scoring
  include SchoolGroupBreadcrumbs

  layout 'group_settings', only: %i[settings]

  load_resource

  before_action :find_partners
  before_action :load_schools, except: [:map, :settings]
  before_action :redirect_unless_authorised, except: [:map, :settings]
  before_action :breadcrumbs
  before_action :find_school_group_fuel_types
  before_action :set_show_school_group_message

  skip_before_action :authenticate_user!

  def show
    respond_to do |format|
      format.html do
        render :show, layout: 'dashboards'
      end
      format.csv do
        send_data SchoolGroups::RecentUsageCsvGenerator.new(school_group: @school_group,
                                                            schools: @schools,
                                                            include_cluster: include_clusters?(@school_group)).export,
                  filename: csv_filename_for('recent_usage')
      end
    end
  end

  def map
    @grouped_schools = @school_group.grouped_schools_by_name(scope: School.visible.includes(:configuration).by_name)
  end

  def comparisons
    redirect_to comparison_reports_school_group_advice_path(@school_group)
  end

  def priority_actions
    redirect_to priorities_school_group_advice_path(@school_group)
  end

  def current_scores
    redirect_to scores_school_group_advice_path(@school_group) and return
  end

  def settings
    redirect_to school_group_path(@school_group) and return unless can?(:manage_settings, @school_group)
  end

  private

  def csv_filename_for(action)
    title = I18n.t("school_groups.titles.#{action}")
    name = "#{@school_group.name}-#{title}-#{Time.zone.now.strftime('%Y-%m-%d')}".parameterize
    "#{name}.csv"
  end

  def set_show_school_group_message
    @show_school_group_message = show_school_group_message?
  end

  def show_school_group_message?
    return false unless @school_group&.dashboard_message

    show_standard_prompts?(@school_group)
  end

  def find_school_group_fuel_types
    @fuel_types = @school_group.fuel_types
  end

  def breadcrumbs
    build_breadcrumbs([name: I18n.t("school_groups.titles.#{action_name}")])
  end

  def find_partners
    @partners = @school_group.partners
  end
end
