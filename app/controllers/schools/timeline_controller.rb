module Schools
  class TimelineController < ApplicationController
    load_and_authorize_resource :school

    skip_before_action :authenticate_user!

    def show
      authorize! :index, Observation
      @academic_year = if params[:academic_year]
                         AcademicYear.find(params[:academic_year])
                       else
                         @school.academic_year_for(Time.zone.today)
                       end
      first_observation = @school.observations.order('at ASC').first
      @active_academic_years = if first_observation
                                 @school.national_calendar.academic_years.where('end_date >= ? AND start_date <= ?', first_observation.at, Time.zone.today)
                               else
                                 []
                               end
      @observations = @school.observations.visible.order('at DESC').where('at BETWEEN ? AND ?', @academic_year.start_date, @academic_year.end_date)
    end
  end
end
