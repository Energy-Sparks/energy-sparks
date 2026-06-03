namespace :after_party do
  desc 'Deployment task: flipper_new_schools_page'
  task flipper_new_schools_page: :environment do
    puts "Running deploy task 'flipper_new_schools_page'"

    Flipper.add(:new_schools_page)
    Flipper.enable_group(:new_schools_page, :admins)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
