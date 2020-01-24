module Programmes
  class Creator
    def initialize(school, programme_type)
      @school = school
      @programme_type = programme_type
    end

    def create
      programme = Programme.create(
        school: @school,
        programme_type: @programme_type,
        started_on: Time.zone.today
      )

      @programme_type.programme_type_activity_types.each do |programme_type_activity_type|
        create_programme_activity(programme, programme_type_activity_type.activity_type, programme_type_activity_type.position)
      end
      programme
    end

    private

    def create_programme_activity(programme, activity_type, position)
      activity = @school.activities.find_by(activity_type: activity_type)
      programme.programme_activities.create!(activity_type: activity_type, position: position, activity: activity)
    end
  end
end
