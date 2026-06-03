namespace :after_party do
  desc 'Deployment task: group_dashboard_feature_flag'
  task group_dashboard_feature_flag: :environment do
    puts "Running deploy task 'group_dashboard_feature_flag'"

    Flipper.add(:group_dashboards_2025)
    Flipper.enable_group(:group_dashboards_2025, :admins)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
