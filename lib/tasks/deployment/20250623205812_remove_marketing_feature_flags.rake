namespace :after_party do
  desc 'Deployment task: remove_marketing_feature_flags'
  task remove_marketing_feature_flags: :environment do
    puts "Running deploy task 'remove_marketing_feature_flags'"

    Flipper.remove(:new_workshops_page)
    Flipper.remove(:new_case_studies_page)
    Flipper.remove(:new_audits_page)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
