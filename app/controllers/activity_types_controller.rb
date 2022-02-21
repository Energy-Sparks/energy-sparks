class ActivityTypesController < ApplicationController
  include Pagy::Backend
  load_and_authorize_resource
  skip_before_action :authenticate_user!, only: [:show, :index]

  def index
    key_stage1 = KeyStage.find_by_name('KS4')
    key_stage2 = KeyStage.find_by_name('KS5')
    subject = Subject.find_by_name('Citizenship')
    if params[:query]
      @pagy, @activity_types = pagy(ActivityType.for_key_stages([key_stage1, key_stage2]).for_subject(subject).search(params[:query]))
    else
      @activity_types = ActivityType.none
    end
  end

  def show
    @recorded = Activity.where(activity_type: @activity_type).count
    @school_count = Activity.select(:school_id).where(activity_type: @activity_type).distinct.count
    if current_user_school
      @activity_type_content = load_content(@activity_type, current_user_school)
      @can_be_completed = can_be_completed(@activity_type, current_user_school)
    else
      @activity_type_content = @activity_type.description
    end
  end

  private

  def can_be_completed(activity_type, school)
    ActivityTypeFilter.new(school: school).activity_types.include?(activity_type)
  end

  def show_data_enabled_activity_type?(activity_type, school)
    activity_type.data_driven? && !school.data_enabled?
  end

  def load_content(activity_type, school)
    interpolator = TemplateInterpolation.new(activity_type, render_with: SchoolTemplate.new(school))
    if show_data_enabled_activity_type?(activity_type, school)
      interpolator.interpolate(:description).description
    else
      interpolator.interpolate(:school_specific_description_or_fallback).school_specific_description_or_fallback
    end
  end
end
