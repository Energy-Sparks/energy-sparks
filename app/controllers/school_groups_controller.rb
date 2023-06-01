class SchoolGroupsController < ApplicationController
  include PartnersHelper

  before_action :find_school_group
  before_action :redirect_unless_feature_enabled, only: [:map, :comparisons, :priority_actions, :current_scores]
  before_action :redirect_unless_authorised, only: [:comparisons, :priority_actions, :current_scores]
  before_action :find_schools_and_partners
  before_action :build_breadcrumbs
  before_action :find_school_group_fuel_types

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
  end

  def priority_actions
  end

  def current_scores
  end

  private

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
    authorize! :show, @school_group
    render 'current_dashboard'
  end

  def enhanced_dashboard
    if can?(:compare, @school_group)
      render 'enhanced_dashboard'
    else
      redirect_to map_school_group_path(@school_group) and return
    end
  end
end
