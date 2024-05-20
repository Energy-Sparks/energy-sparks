namespace :after_party do
  desc 'Deployment task: comparison_reports_redirect'
  task comparison_reports_redirect: :environment do
    puts "Running deploy task 'comparison_reports_redirect'"

    Flipper.enable(:comparison_reports)
    Flipper.enable(:comparison_reports_redirect)
    Flipper.disable(:comparison_reports_link_to_old)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end