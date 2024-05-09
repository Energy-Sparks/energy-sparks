namespace :after_party do
  desc 'Deployment task: enable_comparison_reports_for_admins_feature_flag'
  task enable_comparison_reports_for_admins_feature_flag: :environment do
    puts "Running deploy task 'enable_comparison_reports_for_admins_feature_flag'"

    Flipper.enable_group(:comparison_reports, :admins)
    Flipper.enable_group(:comparison_reports_link_to_old, :admins)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
