module Schools
  class ProgrammesController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource :programme_type
    load_and_authorize_resource :programme

    def index
    end

    def new
      @programme = Programme.create(school: @school, programme_type: @programme_type, title: @programme_type.title)

      @programme_type.activity_types.each do |activity_type|
        position = ProgrammeTypeActivityType.find_by(programme_type: @programme_type, activity_type: activity_type).position
        programme_activity = if @school.activities.find_by(activity_type: activity_type)
                               activity = @school.activities.find_by(activity_type: activity_type)
                               ProgrammeActivity.create(programme: @programme, activity_type: activity_type, position: position, activity: activity)
                             else
                               ProgrammeActivity.create(programme: @programme, activity_type: activity_type, position: position)
                             end

        @programme.programme_activities << programme_activity
      end

      redirect_to school_programme_path(@school, @programme)
    end

    def show
    end
  end
end
