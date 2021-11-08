class ActivityTypesController < ApplicationController
  load_and_authorize_resource
  skip_before_action :authenticate_user!, only: [:show, :index]

  def index
    @activity_types = @activity_types.includes(:activity_category).order("activity_categories.name", :name)
  end

  def show
    @recorded = Activity.where(activity_type: @activity_type).count
    @school_count = Activity.select(:school_id).where(activity_type: @activity_type).distinct.count
    if current_user_school
      @content = load_content(@activity_type, current_user_school)
      @can_be_completed = can_be_completed(@activity_type, current_user_school)
    end
  end

  private

  def can_be_completed(activity_type, school)
    ActivityTypeFilter.new(school: school).activity_types.include?(activity_type)
  end

  def load_content(activity_type, school)
    TemplateInterpolation.new(
      activity_type,
      render_with: SchoolTemplate.new(school)
    ).interpolate(
      :school_specific_description_or_fallback
    )
  end
end
