class SchoolGroupsController < ApplicationController
  include PartnersHelper

  load_and_authorize_resource
  before_action :find_schools_and_partners
  before_action :build_breadcrumbs, exclude: [:show]

  skip_before_action :authenticate_user!, only: [:show, :map]

  def show
    if EnergySparks::FeatureFlags.active?(:enhanced_school_group_dashboard)
      enhanced_dashboard
    else
      current_dashboard
    end
  end

  def map
    redirect_to school_group_path(@school_group) unless EnergySparks::FeatureFlags.active?(:enhanced_school_group_dashboard)
  end

  def recent_usage
    redirect_to school_group_path(@school_group) unless EnergySparks::FeatureFlags.active?(:enhanced_school_group_dashboard)
  end

  def comparisons
    redirect_to school_group_path(@school_group) unless EnergySparks::FeatureFlags.active?(:enhanced_school_group_dashboard)
  end

  def priority_actions
    redirect_to school_group_path(@school_group) unless EnergySparks::FeatureFlags.active?(:enhanced_school_group_dashboard)
  end

  def current_scores
    redirect_to school_group_path(@school_group) unless EnergySparks::FeatureFlags.active?(:enhanced_school_group_dashboard)
  end

  private

  def build_breadcrumbs
    @breadcrumbs = [
      { name: 'Schools' },
      { name: @school_group.name, href: school_group_path(@school_group) },
      { name: I18n.t("school_groups.titles.#{action_name}") }
    ]
  end

  def find_schools_and_partners
    @schools = @school_group.schools.visible.by_name
    @partners = @school_group.partners
  end

  def current_dashboard
    render 'current_dashboard'
  end

  def enhanced_dashboard
    if can?(:show, SchoolGroup)
      @breadcrumbs = [
        { name: 'Schools' },
        { name: @school_group.name, href: school_group_path(@school_group) },
        { name: I18n.t("school_groups.titles.group_dashboard") }
      ]
      render 'enhanced_dashboard'
    else
      redirect_to map_school_group_path(@school_group)
    end
  end
end
