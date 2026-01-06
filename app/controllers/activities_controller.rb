# frozen_string_literal: true

class ActivitiesController < ApplicationController
  include ActivityTypeFilterable

  load_resource :school
  load_and_authorize_resource through: :school

  skip_before_action :authenticate_user!, only: %i[show]

  def show
    interpolator = TemplateInterpolation.new(@activity.activity_type, render_with: SchoolTemplate.new(@school))
    if @activity.activity_type.data_driven? && !@school.data_enabled?
      @activity_type_content = interpolator.interpolate(:description).description
    else
      @activity_type_content = interpolator.interpolate(:school_specific_description_or_fallback).school_specific_description_or_fallback
    end
  end

  def completed; end

  def new
    return if params[:activity_type_id].blank?

    activity_type = ActivityType.find(params[:activity_type_id])
    return if activity_type.blank?

    @activity.activity_type = activity_type
    @activity.activity_category = activity_type.activity_category
  end

  def edit; end

  def create
    if Flipper.enabled?(:todos, current_user)
      if Tasks::Recorder.new(@activity, current_user).process
        redirect_to completed_school_activity_path(@school, @activity)
      else
        render :new
      end
    else
      respond_to do |format|
        if ActivityCreator.new(@activity, current_user).process
          format.html { redirect_to completed_school_activity_path(@school, @activity) }
          format.json { render :show, status: :created, location: @school }
        else
          format.html { render :new }
          format.json { render json: @activity.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def update
    respond_to do |format|
      if @activity.update(activity_params.merge(updated_by: current_user))
        format.html do
          redirect_to school_activity_path(@school, @activity), notice: 'Activity was successfully updated.'
        end
        format.json { render :show, status: :ok, location: @school }
      else
        format.html { render :edit }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @activity.observations.each { |observation| ObservationRemoval.new(observation).process }
    @activity.destroy
    respond_to do |format|
      format.html do
        redirect_to school_activities_path(@school), notice: 'Activity was successfully destroyed.'
      end
      format.json { head :no_content }
    end
  end

  private

  def activity_params
    params.require(:activity).permit(:school_id, :activity_type_id, :title, :description, :happened_on, :content,
                                     :pupil_count)
  end
end
