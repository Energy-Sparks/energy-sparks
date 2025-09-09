class TimelineController < ApplicationController
  include SchoolGroupBreadcrumbs

  load_and_authorize_resource :school
  load_and_authorize_resource :school_group

  before_action :set_timelineable
  skip_before_action :authenticate_user!
  before_action :set_breadcrumbs

  def show
    authorize! :index, Observation

    first_observation = @timelineable.observations.visible.order('at ASC').first
    @observations = [] and return unless first_observation

    years = calendar.academic_years.for_date_onwards(first_observation.at).ordered(:desc)
    counts = @timelineable.observations.with_academic_year.counts_by_academic_year

    @active_academic_years = years.map { |year| [year, counts[year.id] || 0] }

    @observations = @timelineable.observations.visible.in_academic_year(academic_year).by_date
  end

  private

  def set_timelineable
    @timelineable = @school || @school_group
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

  def academic_year
    @academic_year ||= if params[:academic_year]
                         AcademicYear.find(params[:academic_year])
                       else
                         calendar.current_academic_year
                       end
  end
end
