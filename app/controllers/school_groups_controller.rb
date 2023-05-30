class SchoolGroupsController < ApplicationController
  include PartnersHelper

  load_and_authorize_resource
  before_action :find_schools_and_partners

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

  def find_schools_and_partners
    @schools = @school_group.schools.visible.by_name
    @partners = @school_group.partners
  end

  def current_dashboard
    render 'current_dashboard'
  end

  def enhanced_dashboard
    if can?(:show, SchoolGroup)
      render 'enhanced_dashboard'
    else
      redirect_to map_school_group_path(@school_group)
    end
  end
end
