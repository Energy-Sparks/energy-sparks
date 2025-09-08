namespace :after_party do
  desc 'Deployment task: flipper_new_manage_pages'
  task flipper_new_manage_pages: :environment do
    puts "Running deploy task 'flipper_new_manage_pages'"

    Flipper.add(:new_manage_school_pages)
    Flipper.enable_group(:new_manage_school_pages, :admins)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
