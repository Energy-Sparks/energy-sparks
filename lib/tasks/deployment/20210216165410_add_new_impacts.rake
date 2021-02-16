namespace :after_party do
  desc 'Deployment task: Add reducing carbon emissions and increasing energy literacy'
  task add_new_impacts: :environment do
    puts "Running deploy task 'add_new_impacts'"

    Impact.create!(name: "Reduce carbon emissions")
    Impact.create!(name: "Increase energy literacy")

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
