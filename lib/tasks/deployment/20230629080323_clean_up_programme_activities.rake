namespace :after_party do
  desc 'Deployment task: clean_up_programme_activities'
  task clean_up_programme_activities: :environment do
    puts "Running deploy task 'clean_up_programme_activities'"

    programme_activities_without_programme_type = ProgrammeActivity.select do |programme_activity|
      programme_activity.programme&.programme_type.nil?
    end

    invalid_programme_activities = ProgrammeActivity.select do |programme_activity|
      programme_activity&.programme&.programme_type&.activity_types&.pluck(:id)&.exclude?(programme_activity&.activity_type&.id)
    end

    programme_activities_without_programme_type.each { |programme_activity| programme_activity.delete }
    invalid_programme_activities.each { |programme_activity| programme_activity.delete }

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
