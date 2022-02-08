class ActivitiesController < ApplicationController
  include ActivityTypeFilterable

  load_resource :school
  load_and_authorize_resource through: :school

  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @activities = @activities.order(happened_on: :desc)
  end

  def show
    interpolator = TemplateInterpolation.new(@activity.activity_type, render_with: SchoolTemplate.new(@school))
    if show_data_enabled_activity?(@activity, @school)
      @activity_type_content = interpolator.interpolate(:description).description
    else
      @activity_type_content = interpolator.interpolate(:school_specific_description_or_fallback).school_specific_description_or_fallback
    end
  end

  def completed
    if current_user_school
      @suggested_activities = load_suggested_activities(current_user_school)
    end
  end

  def new
    if params[:activity_type_id].present?
      activity_type = ActivityType.find(params[:activity_type_id])
      if activity_type.present?
        @activity.activity_type = activity_type
        @activity.activity_category = activity_type.activity_category
      end
    end
  end

  def edit
  end

  def create
    respond_to do |format|
      if ActivityCreator.new(@activity).process
        format.html { redirect_to completed_school_activity_path(@school, @activity)}
        format.json { render :show, status: :created, location: @school }
      else
        format.html { render :new }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @activity.update(activity_params)
        format.html { redirect_to school_activity_path(@school, @activity), notice: 'Activity was successfully updated.' }
        format.json { render :show, status: :ok, location: @school }
      else
        format.html { render :edit }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @activity.observations.each {|observation| ObservationRemoval.new(observation).process}
    @activity.destroy
    respond_to do |format|
      format.html { redirect_back fallback_location: school_activities_path(@school), notice: 'Activity was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

private

  def activity_params
    params.require(:activity).permit(:school_id, :activity_type_id, :title, :description, :happened_on, :content)
  end

  def show_data_enabled_activity?(activity, school)
    activity.activity_type.data_driven? && !school.data_enabled?
  end

  def load_suggested_activities(school)
    NextActivitySuggesterWithFilter.new(school, activity_type_filter).suggest_for_school_targets(5)
  end
end
