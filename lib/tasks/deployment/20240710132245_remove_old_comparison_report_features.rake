namespace :after_party do
  desc 'Deployment task: remove_old_comparison_report_features'
  task remove_old_comparison_report_features: :environment do
    puts "Running deploy task 'remove_old_comparison_report_features'"

    Flipper.remove(:comparison_reports)
    Flipper.remove(:comparison_reports_redirect)
    Flipper.remove(:comparison_reports_link_to_old)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
