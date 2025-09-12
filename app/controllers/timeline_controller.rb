class TimelineController < ApplicationController
  include SchoolGroupBreadcrumbs
  include SchoolGroupAccessControl
  include NonPublicSchools

  load_and_authorize_resource :school
  load_and_authorize_resource :school_group

  before_action only: [:show], if: -> { @school.present? } do
    redirect_unless_permitted(:show)
  end
  before_action :redirect_unless_authorised, only: [:show], if: -> { @school_group.present? }

  skip_before_action :authenticate_user!

  before_action :timelineable
  before_action :set_breadcrumbs

  def show
    @academic_years = @observations = []

    return unless first_observation

    @academic_years = available_years.map { |year| [year, observation_counts[year.id] || 0] }
    @academic_year = params[:academic_year] ? AcademicYear.find(params[:academic_year]) : available_years.first
    @current_academic_year = calendar.current_academic_year
    @observations = timelineable.observations.visible.in_academic_year(@academic_year).by_date || []
  end

  private

  def timelineable
    @timelineable ||= @school || @school_group
  end

  def set_breadcrumbs
    breadcrumbs = [name: I18n.t('timeline.view_all_events')]
    if @timelineable.is_a?(School)
      @breadcrumbs = breadcrumbs
    else
      build_breadcrumbs(breadcrumbs)
    end
  end

  def calendar
    @calendar ||= @timelineable.is_a?(School) ? @timelineable.national_calendar : @timelineable.scorable_calendar
  end

  def first_observation
    timelineable.observations.visible.order('at ASC').first
  end

  def available_years
    @available_years ||= calendar.academic_years.for_date_onwards(first_observation.at).ordered(:desc)
  end

  def observation_counts
    @observation_counts ||= timelineable.observations.with_academic_year.counts_by_academic_year
  end
end
