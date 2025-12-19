# frozen_string_literal: true

module Programmes
  class Creator
    def initialize(school, programme_type)
      @school = school
      @programme_type = programme_type
    end

    def create(repeat: false)
      if repeat
        @school.programmes.where(programme_type: @programme_type).where.not(status: 'completed')
               .update(status: 'abandoned')
      elsif already_enrolled?
        return
      end

      programme = @school.programmes.create(programme_type: @programme_type, started_on: Time.zone.today)

      programme.complete_todos_this_academic_year!
      programme
    end

    private

    def recognise_existing_progress(programme)
      @programme_type.programme_type_activity_types.each do |programme_type_activity_type|
        activity = latest_activity_this_academic_year(programme_type_activity_type.activity_type)
        if activity.present?
          programme.programme_activities.create!(activity_type: programme_type_activity_type.activity_type,
                                                 activity:)
        end
      end
      programme.complete! if programme.all_activities_complete?
    end

    def latest_activity_this_academic_year(activity_type)
      activities = @school.activities.where(activity_type:).order(happened_on: :desc)
      activities.find { |activity| academic_year_for(activity).present? && academic_year_for(activity).current? }
    end

    def academic_year_for(activity)
      @school.academic_year_for(activity.happened_on)
    end

    def already_enrolled?
      @school.programmes.any? { |programme| programme.programme_type == @programme_type }
    end
  end
end
