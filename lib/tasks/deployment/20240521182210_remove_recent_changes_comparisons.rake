namespace :after_party do
  desc 'Deployment task: remove_recent_changes_comparisons'
  task remove_recent_changes_comparisons: :environment do
    puts "Running deploy task 'remove_recent_changes_comparisons'"

    Comparison::Report.destroy_by(key: :change_in_electricity_consumption_recent_school_weeks)
    Comparison::Report.destroy_by(key: :change_in_gas_consumption_recent_school_weeks)

    # Put your task implementation HERE.

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
