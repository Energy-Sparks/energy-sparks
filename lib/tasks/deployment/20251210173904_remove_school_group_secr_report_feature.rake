namespace :after_party do
  desc 'Deployment task: remove_school_group_secr_report_feature'
  task remove_school_group_secr_report_feature: :environment do
    puts "Running deploy task 'remove_school_group_secr_report_feature'"

    Flipper.remove(:school_group_secr_report)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
