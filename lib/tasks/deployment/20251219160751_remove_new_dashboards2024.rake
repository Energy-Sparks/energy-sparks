namespace :after_party do
  desc 'Deployment task: remove_new_dashboards2024'
  task remove_new_dashboards2024: :environment do
    puts "Running deploy task 'remove_new_dashboards2024'"

    Flipper.remove(:new_dashboards_2024)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
