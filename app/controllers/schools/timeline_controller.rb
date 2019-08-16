module Schools
  class TimelineController < ApplicationController
    load_and_authorize_resource :school
    def show
      @academic_year = if params[:academic_year]
                         AcademicYear.find(params[:academic_year])
                       else
                         @school.calendar_area.academic_year_for(Time.zone.today)
                       end
      first_observation = @school.observations.order('at ASC').first
      if first_observation
        @active_academic_years = @school.calendar_area.parent_area.academic_years.where('end_date >= ? AND start_date <= ?', first_observation.at, Time.zone.today)
      else
        @academic_years = []
      end
      @observations = @school.observations.order('at DESC').where('at BETWEEN ? AND ?', @academic_year.start_date, @academic_year.end_date)
    end
  end
end
