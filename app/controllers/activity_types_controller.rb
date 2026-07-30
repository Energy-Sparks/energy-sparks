# frozen_string_literal: true

class ActivityTypesController < ApplicationController
  include Pagy::Method

  layout 'task', only: [:show]

  before_action :enable_bootstrap5, only: [:show]
  before_action :handle_head_request, only: [:show]

  load_and_authorize_resource
  before_action :set_breadcrumbs, only: [:show]

  skip_before_action :authenticate_user!, only: %i[show search for_school]

  def search
    if params[:query]
      activity_types = ActivityTypeSearchService.search(params[:query], key_stages, subjects, I18n.locale)
      @pagy, @activity_types = pagy(activity_types)
    else
      @activity_types = []
    end
  end

  def show
    @recorded = Activity.where(activity_type: @activity_type).count
    @school_count = Activity.select(:school_id).where(activity_type: @activity_type).distinct.count
    @activity_type_content = if current_user_school
                               load_content(@activity_type, current_user_school)
                             else
                               @activity_type.description
                             end
    @available_schools_for_user = available_schools_for_user(@activity_type, current_user) if current_user
  end

  def for_school
    school = School.find(params[:school_id])
    redirect_to new_school_activity_path(school, activity_type_id: @activity_type.id)
  end

  private

  def available_schools_for_user(activity_type, user)
    return user.schools if user.admin?

    user.schools(current_ability:).select do |school|
      ActivityTypeFilter.new(school: school).activity_types.include?(activity_type)
    end
  end

  def load_content(activity_type, school)
    interpolator = TemplateInterpolation.new(activity_type, render_with: SchoolTemplate.new(school))
    if activity_type.data_driven? && !school.data_enabled?
      interpolator.interpolate(:description).description
    else
      interpolator.interpolate(:school_specific_description_or_fallback).school_specific_description_or_fallback
    end
  end

  def key_stages
    limit_params(:key_stages, KeyStage)
  end

  def subjects
    limit_params(:subjects, Subject)
  end

  def limit_params(name, model)
    if params[name]
      model.where(name: params[name].split(',').map { |s| CGI.unescape(s.strip) })
    else
      []
    end
  end

  def add_or_remove(list, item)
    item = CGI.escape(item)
    arr = list ? list.split(',').map(&:strip) : []
    arr.include?(item) ? arr.delete(item) : arr.append(item)
    arr.join(',')
  end

  def activity_types_search_link(key_stage, subject)
    query = params[:query]
    key_stages = params[:key_stages]
    subjects = params[:subjects]
    search_activity_types_path(query:,
                               key_stages: add_or_remove(key_stages, key_stage),
                               subjects: add_or_remove(subjects, subject))
  end
  helper_method :activity_types_search_link

  def activity_types_badge_class(list, item, color)
    item = CGI.escape(item)
    ['badge', list&.include?(item) ? "text-bg-#{color}" : 'text-bg-light outline'].join(' ')
  end
  helper_method :activity_types_badge_class

  def set_breadcrumbs
    category = @activity_type.category

    @breadcrumbs = [
      { name: t('common.labels.pupil_activities'), href: activity_categories_path },
      ({ name: category.name, href: activity_category_path(category) } if category),
      { name: @activity_type.name }
    ].compact
  end
end
