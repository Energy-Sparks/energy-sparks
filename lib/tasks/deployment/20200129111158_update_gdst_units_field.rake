namespace :after_party do
  desc 'Deployment task: update_gdst_units_field'
  task update_gdst_units_field: :environment do
    puts "Running deploy task 'update_gdst_units_field'"

    AmrDataFeedConfig.where(identifier: ['gdst-historic-electricity','gdst-electricity']).update_all(units_field: 'Data Type')

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
