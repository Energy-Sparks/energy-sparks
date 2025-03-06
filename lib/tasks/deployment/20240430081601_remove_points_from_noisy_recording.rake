namespace :after_party do
  desc 'Deployment task: remove_points_from_noisy_recording'
  task remove_points_from_noisy_recording: :environment do
    puts "Running deploy task 'remove_points_from_noisy_recording'"

    # Remove points from any recorded observations of this type, that have been record more than the
    # allowed times, that have been recorded this academic year
    def remove_points_from_recordings(school, intervention_type, allowed)
      academic_year = school.academic_year_for(Time.zone.today)
      return unless academic_year
      observations = school.observations.where(intervention_type: intervention_type).where(at: academic_year.start_date..academic_year.end_date).order(at: :asc).offset(allowed)
      # update individually rather than in bulk to avoid issues with BETWEEN
      observations.each do |observation|
        observation.update(points: 0)
      end
    end

    school = School.find('harris-academy-chobham')
    # Add timers to printers, only once a year
    remove_points_from_recordings(school, InterventionType.find(47), 1)

    school = School.find('malet-lambert')
    # Checking windows are closed.
    remove_points_from_recordings(school, InterventionType.find(48), 10)
    # Holiday turn off
    remove_points_from_recordings(school, InterventionType.find(70), 2)
    # turned off fridges/freezers in school holidays
    remove_points_from_recordings(school, InterventionType.find(37), 1)

    school = School.find('south-hunsley-school-and-sixth-form-college')
    # Checking windows are closed.
    remove_points_from_recordings(school, InterventionType.find(48), 10)
    # Switched off fume cupboards
    remove_points_from_recordings(school, InterventionType.find(34), 10)

    school = School.find('stoke-park-primary-school')
    # Switched off lights and IT equipment after school
    remove_points_from_recordings(school, InterventionType.find(33), 10)

    school = School.find('the-snaith-school')
    # Switched off lights and IT equipment after school
    remove_points_from_recordings(school, InterventionType.find(33), 10)
    # Checking windows are closed.
    remove_points_from_recordings(school, InterventionType.find(48), 10)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
