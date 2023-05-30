class SchoolGroupsController < ApplicationController
  include PartnersHelper

  load_and_authorize_resource

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

  private

  def current_dashboard
    @schools = @school_group.schools.visible.by_name
    @partners = @school_group.partners
    render 'current_dashboard'
  end

  def enhanced_dashboard
    if can?(:show, SchoolGroup)
      @schools = @school_group.schools.visible.by_name
      @partners = @school_group.partners
      render 'enhanced_dashboard'
    else
      redirect_to map_school_group_path(@school_group)
    end
  end
end
