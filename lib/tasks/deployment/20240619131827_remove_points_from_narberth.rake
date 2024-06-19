namespace :after_party do
  desc 'Deployment task: remove_points_from_narberth'
  task remove_points_from_narberth: :environment do
    puts "Running deploy task 'remove_points_from_narberth'"

    # Remove points from any recorded observations of this type, that have been record more than the
    # allowed times, that have been recorded this academic year
    def remove_points_from_activity_recordings(school, activity_type, allowed)
      academic_year = school.academic_year_for(Time.zone.today)
      return unless academic_year
      activities = school.activities.where(activity_type: activity_type).where(happened_on: academic_year.start_date..academic_year.end_date).order(happened_on: :asc).offset(allowed)
      observations = school.observations.where(activities: activities)
      # update individually rather than in bulk to avoid issues with BETWEEN
      observations.each do |observation|
        observation.update(points: 0)
      end
    end

    school = School.find('narberth-community-primary-school')

    # Analyse your school energy use - review heating
    # Analyse your school energy use - what's happening in the school kitchen?
    # Declare a Climate Emergency
    # Examine the carbon emissions from UK's electricity generation
    # Hold a sustainable travel theme day
    # How has installation of our heat pump changed our energy consumption
    # Making sense of our school's carbon footprint
    # Participate in an Introduction to Energy Sparks workshop
    # Review heating performance of your heat pump
    # Understand your school's baseload
    activity_type_ids = [116, 118, 88, 151, 170, 182, 84, 145, 181, 113]

    activity_type_ids.each do |activity_type_id|
      activity_type = ActivityType.find(activity_type_id)
      remove_points_from_activity_recordings(school, activity_type, 2)
      activity_type.update!(maximum_frequency: 2)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
