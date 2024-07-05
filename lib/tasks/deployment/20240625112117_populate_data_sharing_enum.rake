namespace :after_party do
  desc 'Deployment task: populate_data_sharing_enum'
  task populate_data_sharing_enum: :environment do
    puts "Running deploy task 'populate_data_sharing_enum'"

    # As currently implemented schools that are not public do not have
    # public dashboards, analysis or comparisons. But other school users in
    # the same group can still access the analysis.
    School.where(public: false).update_all(data_sharing: :within_group)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
