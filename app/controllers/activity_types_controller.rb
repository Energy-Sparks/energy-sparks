class ActivityTypesController < ApplicationController
  include Pagy::Backend
  load_and_authorize_resource
  skip_before_action :authenticate_user!, only: [:show, :search, :for_school]

  def search
    @key_stages = key_stages
    @subjects = subjects
    if params[:query]
      activity_types = ActivityTypeSearchService.search(params[:query], @key_stages, @subjects, I18n.locale)
      @pagy, @activity_types = pagy(activity_types)
    else
      @activity_types = []
    end
  end

  def show
    @recorded = Activity.where(activity_type: @activity_type).count
    @school_count = Activity.select(:school_id).where(activity_type: @activity_type).distinct.count
    if current_user_school
      @activity_type_content = load_content(@activity_type, current_user_school)
      #ensure that embedded charts, etc are working
      if show_data_enabled_activity_type?(@activity_type, current_user_school)
        @activity_type_content = @activity_type_content.body.to_html.html_safe
      end
    else
      @activity_type_content = @activity_type.description
    end
    @can_be_completed_for_schools = can_be_completed_for_schools(@activity_type, current_user.schools) if current_user
  end

  def for_school
    school = School.find(params[:school_id])
    redirect_to new_school_activity_path(school, activity_type_id: @activity_type.id)
  end

  private

  def can_be_completed_for_schools(activity_type, schools)
    schools.select do |school|
      ActivityTypeFilter.new(school: school).activity_types.include?(activity_type)
    end
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

  def key_stages
    if params[:key_stages]
      KeyStage.where(name: params[:key_stages].split(',').map(&:strip))
    else
      []
    end
  end

  def subjects
    if params[:subjects]
      Subject.where(name: params[:subjects].split(',').map(&:strip))
    else
      []
    end
  end
end
