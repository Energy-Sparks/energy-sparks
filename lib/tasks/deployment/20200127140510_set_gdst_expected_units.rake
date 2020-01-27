namespace :after_party do
  desc 'Deployment task: set_gdst_expected_units'
  task set_gdst_expected_units: :environment do
    puts "Running deploy task 'set_gdst_expected_units'"

    AmrDataFeedConfig.where(identifier: ['gdst-historic-electricity','gdst-electricity']).update_all(expected_units: 'kWh')


    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
