namespace :after_party do
  desc 'Deployment task: complete_started_already_completed_programmes'
  task complete_started_already_completed_programmes: :environment do
    puts "Running deploy task 'complete_started_already_completed_programmes'"

    Programme.started.each do |programme|
      if programme.all_activities_complete?
        puts "Setting programme '#{programme.programme_type.title}' to complete for school: #{programme.school.name}"
        programme.ended_on = programme.started_on
        programme.status = :completed
        programme.add_observation
        programme.save!
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end