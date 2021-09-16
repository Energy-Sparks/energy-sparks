module Programmes
  class Creator
    def initialize(school, programme_type)
      @school = school
      @programme_type = programme_type
    end

    def create
      return if already_enrolled?
      programme = @school.programmes.create(
        programme_type: @programme_type,
        started_on: Time.zone.today
      )
      recognise_existing_progress(programme)
      programme
    end

    private

    def recognise_existing_progress(programme)
      @programme_type.programme_type_activity_types.each do |programme_type_activity_type|
        activity = latest_activity_this_academic_year(programme_type_activity_type.activity_type)
        if activity.present?
          programme.programme_activities.create!(activity_type: programme_type_activity_type.activity_type, activity: activity)
        end
      end
    end

    def latest_activity_this_academic_year(activity_type)
      activities = @school.activities.where(activity_type: activity_type).order(happened_on: :desc)
      activities.find { |activity| academic_year_for(activity).present? && academic_year_for(activity).current? }
    end

    def academic_year_for(activity)
      @school.academic_year_for(activity.happened_on)
    end

    def already_enrolled?
      enrolled = false
      @school.programmes.each do |programme|
        enrolled = programme.programme_type == @programme_type
      end
      enrolled
    end
  end
end
