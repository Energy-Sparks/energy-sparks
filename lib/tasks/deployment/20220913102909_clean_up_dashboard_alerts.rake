namespace :after_party do
  desc 'Deployment task: Clean up DashboardAlert records to remove all unused public & teacher alerts'
  task clean_up_dashboard_alerts: :environment do
    puts "Running deploy task 'clean_up_dashboard_alerts'"

    DashboardAlert.where(dashboard: %w[public teacher]).delete_all

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
