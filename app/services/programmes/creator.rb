module Programmes
  class Creator
    def initialize(school, programme_type)
      @school = school
      @programme_type = programme_type
    end

    def create
      @programme = Programme.create(school: @school, programme_type: @programme_type, title: @programme_type.title)

      @programme_type.activity_types.each do |activity_type|
        @programme.programme_activities << programme_activity(activity_type)
      end
      @programme
    end

    private

    def programme_activity(activity_type)
      position = position(activity_type)

      if @school.activities.find_by(activity_type: activity_type)
        activity = @school.activities.find_by(activity_type: activity_type)
        ProgrammeActivity.create(programme: @programme, activity_type: activity_type, position: position, activity: activity)
      else
        ProgrammeActivity.create(programme: @programme, activity_type: activity_type, position: position)
      end
    end

    def position(activity_type)
      ProgrammeTypeActivityType.find_by(programme_type: @programme_type, activity_type: activity_type).position
    end
  end
end
