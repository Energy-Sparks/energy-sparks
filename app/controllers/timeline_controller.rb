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
    @observations = observations.in_academic_year(@academic_year).most_recent || []
    @end_date = @academic_year == @current_academic_year ? @observations.first&.at : @academic_year.end_date
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
    @calendar ||= @timelineable.national_calendar || Calendar.default_national
  end

  def observations
    timelineable.observations.for_visible_schools.visible
  end

  def first_observation
    observations.order('at ASC').first
  end

  def available_years
    @available_years ||= calendar.academic_years.for_date_onwards(first_observation.at).ordered(:desc)
  end

  def observation_counts
    @observation_counts ||= observations.counts_by_academic_year
  end
end
