# frozen_string_literal: true

class ActivitiesController < ApplicationController
  include ActivityTypeFilterable

  before_action :enable_bootstrap5, except: %i[show]
  skip_before_action :authenticate_user!, only: %i[show]
  load_resource :school
  load_and_authorize_resource through: :school
  before_action :set_breadcrumbs, only: %i[new create edit update]

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

    @activity.activity_type = ActivityType.find(params[:activity_type_id])
    @activity.activity_category = @activity.activity_type.activity_category
  end

  def edit; end

  def create
    if Tasks::Recorder.new(@activity, current_user).process
      redirect_to completed_school_activity_path(@school, @activity)
    else
      render :new
    end
  end

  def update
    if @activity.update(activity_params.merge(updated_by: current_user))
      redirect_to school_activity_path(@school, @activity), notice: I18n.t('activities.notices.updated')
    else
      render :edit
    end
  end

  def destroy
    @activity.observations.each { |observation| ObservationRemoval.new(observation).process }
    @activity.destroy
    redirect_to school_activities_path(@school), notice: I18n.t('activities.notices.removed')
  end

  private

  def activity_params
    params.require(:activity).permit(:school_id, :activity_type_id, :title, :description, :happened_on, :content,
                                     :pupil_count)
  end

  def activity_type
    @activity_type ||=
      if params[:activity_type_id].present?
        ActivityType.find(params[:activity_type_id])
      elsif @activity.present?
        @activity.activity_type
      end
  end

  def set_breadcrumbs
    return unless activity_type

    activity_type.category
    @breadcrumbs = [
      { name: t('common.labels.pupil_activities'), href: activity_categories_path },
      { name: activity_type.name, href: activity_type_path(activity_type) },
      { name: t('activities.new.page_title') }
    ].compact
  end
end
