class TimelineController < ApplicationController
  include SchoolGroupBreadcrumbs
  include SchoolGroupAccessControl
  include NonPublicSchools
  include Pagy::Backend

  load_resource :school
  load_resource :school_group

  skip_before_action :authenticate_user!

  before_action only: [:show], if: -> { @school.present? } do
    redirect_unless_permitted(:show)
  end
  before_action :redirect_unless_authorised, only: [:show], if: -> { @school_group.present? }

  before_action :timelineable
  before_action :set_i18n_scope
  before_action :set_breadcrumbs

  def show
    @academic_years = @observations = []
    return unless first_observation

    @academic_years = available_years.map { |year| [year, observation_counts[year.id] || 0] }
    @academic_year = params[:academic_year] ? AcademicYear.find(params[:academic_year]) : available_years.first
    @current_academic_year = calendar.current_academic_year
    @end_date = @academic_year == @current_academic_year ? Time.zone.today : @academic_year.end_date
    @observations = timelineable.observations.visible.between(@academic_year.start_date, @end_date.end_of_day).by_date || []
    @pagy, @observations = pagy(@observations, limit: 50)
  end

  private

  def timelineable
    @timelineable ||= @school || @school_group
  end

  def set_i18n_scope
    @i18n_scope = timelineable.is_a?(School) ? :schools : :school_groups
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
    @calendar ||= @timelineable.national_calendar
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
