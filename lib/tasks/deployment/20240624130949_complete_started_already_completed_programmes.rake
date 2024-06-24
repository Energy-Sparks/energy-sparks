namespace :after_party do
  desc 'Deployment task: complete_started_already_completed_programmes'
  task complete_started_already_completed_programmes: :environment do
    puts "Running deploy task 'complete_started_already_completed_programmes'"

    Programme.started.each do |programme|
      programme.complete! if programme.all_activities_complete?
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end