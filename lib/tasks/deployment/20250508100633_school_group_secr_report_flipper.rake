namespace :after_party do
  desc 'Deployment task: school_group_secr_report_flipper'
  task school_group_secr_report_flipper: :environment do
    puts "Running deploy task 'school_group_secr_report_flipper'"

    Flipper.enable_group(:school_group_secr_report, :admins)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
